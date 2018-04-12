# frozen_string_literal: true

require 'cartage/plugin'

# A reliable way to create packages.
class Cartage
  # Manage packages in remote storage.
  #
  # == Configuration
  #
  # cartage-s3 is configured in the <tt>plugins.s3</tt> section of the Cartage
  # configuration file. It supports two primary keys:
  #
  # +destinations+:: A dictionary of destinations, as described below, that
  #                  indicate the remote storage location. The destination keys
  #                  will be used as the +destination+ value.
  # +destination+:: The name of the target destination to be used. If missing,
  #                 uses the +default+ location.
  #
  # For backwards compatability, a single destination may be specified in-line
  # with these keys. This destination will become the +default+ destination
  # unless one is already specified in the +destinations+ dictionary (which is
  # an error).
  #
  # === Destinations
  #
  # A destination describes the remote location for packages. It supports two
  # keys:
  #
  # +path+:: The path or bucket name where the targets will be uploaded.
  # +credentials+:: A dictionary used to initialize a Fog::Storage object.
  #
  # === Examples
  #
  # An existing configuration would work implicitly. Assuming an AWS S3 bucket
  # in us-west-2, the two configurations below are identical:
  #
  #   # Implicit
  #   plugins:
  #     s3:
  #       path: PATHNAME
  #       credentials:
  #         provider: AWS
  #         aws_access_key_id: YOUR_AWS_ACCESS_KEY_ID
  #         aws_secret_access_key: YOUR_AWS_SECRET_ACCESS_KEY
  #         region: us-west-2
  #
  #   # Explicit
  #   plugins:
  #     s3:
  #       destination: default
  #       destinations:
  #         default:
  #           path: PATHNAME
  #           credentials:
  #             provider: AWS
  #             aws_access_key_id: YOUR_AWS_ACCESS_KEY_ID
  #             aws_secret_access_key: YOUR_AWS_SECRET_ACCESS_KEY
  #             region: us-west-2
  #
  # A configuration for Rackspace CloudFiles (London datacentre), the explicit
  # configuration would be:
  #
  #   plugins:
  #     s3:
  #       destination: rackspace
  #       destinations:
  #         rackspace:
  #           path: PATHNAME
  #           credentials:
  #             provider: Rackspace
  #             rackspace_username: RACKSPACE_USERNAME
  #             rackspace_api_key: RACKSPACE_API_KEY
  #             rackspace_auth_url: lon.auth.api.rackspacecloud.com
  #
  # For Google Cloud Storage, it would be:
  #
  #   plugins:
  #     s3:
  #       destination: google
  #       destinations:
  #         google:
  #           path: PATHNAME
  #           credentials:
  #             provider: Google
  #             google_storage_access_key_id: YOUR_SECRET_ACCESS_KEY_ID
  #             google_storage_secret_access_key: YOUR_SECRET_ACCESS_KEY
  #
  # === Remote Storage Security Considerations
  #
  # cartage-s3 has multiple modes:
  #
  # * Put (<tt>cartage s3 put</tt>) expects that the target path (or bucket)
  #   will already exist and that the user credentials present will grant direct
  #   write access to the target path without enumeration.
  # * Get (<tt>cartage s3 get</tt>) expects that direct read access to the
  #   target path will be granted.
  # * List (<tt>cartage s3 ls</tt>) expects that listing capability on the target
  #   path will be granted.
  # * Remove (<tt>cartage s3 rm</tt>) expects that deletion capability on the
  #   target path and files will be granted.
  #
  # These permissions are only needed for the optionas listed.
  class S3 < Cartage::Plugin
    VERSION = '2.1' #:nodoc:

    # Put packages and metadata to the remote location.
    def put
      check_config(require_destination: true)
      cartage.display "Uploading to #{name}..."
      put_file cartage.final_release_metadata_json
      cartage.plugins.request_map(:build_package, :package_name).each do |name|
        put_file name
      end
    end

    # Get packages and metadata from the remote location into
    # +local_path+.
    def get(local_path)
      check_config(require_destination: true)
      local_path = Pathname(local_path)
      cartage.display "Downloading from #{name} to #{local_path}..."
      get_file local_path, cartage.final_release_metadata_json
      cartage.plugins.request_map(:build_package, :package_name).each do |name|
        get_file local_path, name
      end
    end

    # List files in the remote destination. If +show_all+ is +false+, the
    # default, only files related to the current Cartage configuration will be
    # shown.
    def list(show_all = false)
      check_config(require_destination: true)
      cartage.display "Showing packages in #{name}..."
      connection.directories.get(destination.path).files.each do |file|
        next unless show_all || file.key =~ /#{cartage.name}/
        puts file.key
      end
    end

    # Remove the metadata and packages from the remote destination.
    def delete
      check_config(require_destination: true)
      cartage.display "Removing packages from #{name}..."
      delete_file Pathname("#{cartage.final_name}-release-hashref.txt")
      delete_file cartage.final_release_metadata_json
      cartage.plugins.request_map(:build_package, :package_name).each do |name|
        delete_file name
      end
    end

    # Check that the configuration is correct. If +require_destination+ is
    # present, an exception will be thrown if a destination is required and not
    # present.
    def check_config(require_destination: false)
      verify_destinations(cartage.config(for_plugin: :s3).destinations)
      fail "No destination #{name} present" if require_destination && !destination
    end

    private

    attr_reader :name
    attr_reader :destination

    def resolve_plugin_config!(s3_config)
      if s3_config.dig(:path) || s3_config.dig(:credentials)
        if s3_config.dig(:destinations, :default)
          fail ArgumentError,
            'Cannot configure both an implicit and explicit default destination.'
        end

        unless s3_config.path && s3_config.credentials
          fail ArgumentError, 'Cannot configure an implicit default ' \
            'destination without both path and credentials.'
        end

        s3_config.destinations ||= OpenStruct.new
        s3_config.destinations.default ||= OpenStruct.new(
          path: s3_config.path,
          credentials: s3_config.credentials
        )
        s3_config.delete_field(:path)
        s3_config.delete_field(:credentials)
      end

      @name = s3_config.destination || 'default'
      @destination = s3_config.dig(:destinations, name)

      verify_destination!(name, destination) if destination
    end

    def verify_destinations(destinations)
      if destinations.nil? || destinations.to_h.empty?
        fail ArgumentError, 'No destinations present'
      end

      destinations.each_pair do |name, destination|
        verify_destination(name, destination)
      end
    end

    def verify_destination(name, destination, &notify)
      notify ||= ->(message) { warn message }

      destination.dig(:path) ||
        notify.("Destination #{name} invalid: No path present")
      destination.dig(:credentials, :provider) ||
        notify.("Destination #{name} invalid: No provider present")
    end

    def verify_destination!(name, destination)
      verify_destination(name, destination) { |message| fail ArgumentError, message }
    end

    #:nocov:
    def connection
      unless defined?(@connection)
        require 'fog'
        @connection = Fog::Storage.new(destination.credentials.to_h)
      end
      @connection
    end

    def put_file(file)
      cartage.display "...put #{file.basename}"
      connection.put_object destination.path, file.basename.to_s, file.read
    end

    def get_file(local_path, file)
      cartage.display "...get #{file.basename}"
      response = connection.get_object(destination.path, file.basename.to_s)
      local_path.join(file.basename).write(response.body)
    end

    def delete_file(file)
      cartage.display "...delete #{file.basename}"
      connection.delete_object destination.path, file.basename.to_s
    end
    #:nocov:
  end
end
