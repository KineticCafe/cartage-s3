begin
  require 'psych'
rescue LoadError
end
require 'yaml'
require 'erb'
require 'cartage/plugin'

class Cartage
  # Upload the target package to S3.
  #
  # == Configuration
  # Cartage::S3 is configured in the +plugins.s3+ section of the Cartage
  # configuration file, and supports the following keys:
  #
  # +path+:: The path name or bucket name where the targets will be uploaded.
  #          The <tt>--path</tt> option will override a config-provided path
  #          setting.
  # +credentials+:: A dictionary which, if present, will be used to initialize
  #                 a Fog::Storage object. If +credentials+ is set in a
  #                 configuration file, the command-line parameters
  #                 <tt>--key-id</tt>, <tt>--secret-key</tt>, and
  #                 <tt>--region</tt> will be ignored.
  #
  # For AWS in us-west-2, this configuration would look like this:
  #
  #   ---
  #   plugins:
  #     s3:
  #       path: PATHNAME
  #       credentials:
  #         provider: AWS
  #         aws_access_key_id: YOUR_AWS_ACCESS_KEY_ID
  #         aws_secret_access_key: YOUR_AWS_SECRET_ACCESS_KEY
  #         region: us-west-2
  #
  # For Rackspace CloudFiles London, it would be:
  #
  #   ---
  #   plugins:
  #     s3:
  #       path: PATHNAME
  #       credentials:
  #         provider: Rackspace
  #         rackspace_username: RACKSPACE_USERNAME
  #         rackspace_api_key: RACKSPACE_API_KEY
  #         rackspace_auth_url: lon.auth.api.rackspacecloud.com
  #
  # For Google Cloud Storage, it would be:
  #
  #   ---
  #   plugins:
  #     s3:
  #       path: PATHNAME
  #       credentials:
  #         provider: Google
  #         google_storage_access_key_id: YOUR_SECRET_ACCESS_KEY_ID
  #         google_storage_secret_access_key: YOUR_SECRET_ACCESS_KEY
  #
  # If Cartage#environment has been set, that value will be used to select
  # partitioned configuration values.
  #
  #   ---
  #   development:
  #     plugins:
  #       s3:
  #         path: PATHNAME
  #         credentials:
  #           provider: AWS
  #           aws_access_key_id: YOUR_AWS_ACCESS_KEY_ID
  #           aws_secret_access_key: YOUR_AWS_SECRET_ACCESS_KEY
  #           region: us-west-2
  #
  # === Cloud Storage Security Considerations
  #
  # cartage-s3 does not create the target path and expects to place both
  # files in the same directory. The only thing that is required from the
  # access user is that it may put a file directly into the bucket/path. The
  # files in question are timestamped UTC, so there is little chance for
  # collision.
  class S3 < Cartage::Plugin
    VERSION = '1.0' #:nodoc:

    # The AWS S3 path (bucket) to use for uploading the cartage package.
    attr_accessor :path
    # The AWS S3 Access Key ID. If a +credentials+ section is not present in
    # the configuration file and this is not provided, this will be pulled from
    # <tt>$AWS_ACCESS_KEY_ID</tt>.
    attr_accessor :aws_access_key_id
    # The AWS S3 Secret Access Key. If a +credentials+ section is not present
    # in the configuration file and this is not provided, this will be pulled
    # from <tt>$AWS_SECRET_ACCESS_KEY</tt>.
    attr_accessor :aws_secret_access_key
    # The AWS S3 Region name.
    attr_accessor :region

    # Perform the upload.
    def upload
      require 'fog'

      connection = Fog::Storage.new(@access)

      @cartage.display "Uploading #{@cartage.final_release_hashref.basename}..."
      connection.put_object(@target, @cartage.final_release_hashref.basename.to_s,
                            @cartage.final_release_hashref.read)
      @cartage.display "Uploading #{@cartage.final_tarball.basename}..."
      connection.put_object(@target, @cartage.final_tarball.basename.to_s,
                            @cartage.final_tarball.read)
    end

    private

    def resolve_config!(s3_config)
      @target = s3_config && s3_config.path

      @access = if s3_config && s3_config.credentials
                  s3_config.credentials.to_h
                else
                  {
                    provider:              'AWS',
                    aws_access_key_id:     value_for!(:aws_access_key_id),
                    aws_secret_access_key: value_for!(:aws_secret_access_key),
                    region:                region
                  }
                end

      provider = @access[:provider]
      raise ArgumentError, <<-exception if provider.nil? or provider.empty?
Cannot upload: no provider set.
      exception

      @target = path || @target
      raise ArgumentError, <<-exception if @target.nil? or @target.empty?
Cannot upload to #{provider}: path is not set.
      exception
    end

    def value_for!(name)
      (send(name) || ENV[name.to_s.upcase]).tap do |value|
        raise ArgumentError, <<-exception if value.nil? or value.empty?
Cannot upload: AWS S3 requires #{name.to_s.upcase} be provided.
        exception
      end
    end

    def self.commands
      require_relative 's3/command'
      [ Cartage::S3::Command ]
    end
  end
end
