# frozen_string_literal: true

Cartage::CLI.extend do
  desc 'Manage packages in remote storage'
  long_desc <<-'DESC'
Commands to upload, download, list, or delete packages and package metadata to
remote storage.
  DESC
  command 's3' do |s3|
    s3.desc 'The name of the remote destination'
    s3.long_desc <<-'DESC'
The name of the defined remote destination in the Cartage configuration file.
If the destination does not exist in the configuration, an error will be
reported.
    DESC
    s3.flag %i(D destination), arg_name: :DESTINATION, default_value: :default

    # Handle common S3 options.
    def handle_s3_options(options) # :nodoc:
      options = options[GLI::Command::PARENT] until options.key?(:destination)
      options[:destination] = nil if options[:destination] == :default

      s3_config = cartage.config(for_plugin: :s3)
      destination = (options[:destination] || s3_config.destination || :default).to_sym

      unless s3_config.dig(:destinations, destination)
        message = if options[:destination] || s3_config.destination
                    "Destination '#{destination}' does not exist."
                  else
                    'Default destination does not exist.'
                  end
        fail ArgumentError, message
      end

      s3_config.destination = destination
    end

    # Commands that declare this require a timestamp.
    def require_timestamp(command_in_context) # :nodoc:
      return if cartage.config.timestamp
      fail GLI::MissingRequiredArgumentsException.new(
        'Timestamp required', command_in_context
      )
    end

    s3.desc 'Put packages into remote storage'
    s3.long_desc <<-'DESC'
Uploads packages and metadata from a previous build to remote storage. This
command requires that a timestamp is provided, either through a Cartage
configuration file or through the global --timestamp flag.

Any active plug-in supporting :build_package requests will provide a package
name to be uploaded. If the package file does not exist locally, an error will
occur.
    DESC
    s3.command %w(put upload) do |put|
      put.action do |_global, options, _args|
        require_timestamp('s3 put')
        handle_s3_options(options)

        cartage.s3.put
      end
    end

    s3.desc 'Get packages from remote storage'
    s3.long_desc <<-'DESC'
Downloads packages from remote storage. This command requires that a timestamp
is provided, either through a Cartage configuration file or through a global
--timestamp flag.

Any active plug-in supporting :build_package requests will provide a package
name to be downloaded. If the package file does not exist remotely, an error
will occur.
    DESC
    s3.command %w(get download) do |get|
      get.desc 'The local path to write packages'
      get.flag :'local-path', default_value: :$PWD

      get.action do |_global, options, _args|
        require_timestamp('s3 get')
        handle_s3_options(options)

        local_path = case options[:'local-path']
                     when :$PWD
                       Dir.pwd
                     else
                       options[:'local-path']
                     end

        cartage.s3.get(local_path)
      end
    end

    s3.desc 'List packages in remote storage'
    s3.long_desc <<-'DESC'
Lists packages in remote storage. Shows packages related to the current Cartage
project name unless --all is provided.
    DESC
    s3.command %w(ls list) do |list|
      list.desc 'Show all files in remote storage'
      list.switch [ :all ], negatable: false

      list.action do |_global, options, _args|
        handle_s3_options(options)

        cartage.s3.list(options[:all])
      end
    end

    s3.desc 'Delete packages from remote storage'
    s3.long_desc <<-'DESC'
Removes packages from remote storage. This command requires that a timestamp is
provided, either through a Cartage configuration file or through a global
--timestamp flag.

Any active plug-in supporting :build_package requests will provide a package
name to be removed. If the package file does not exist remotely, an error will
occur.
    DESC
    s3.command %w(rm delete) do |delete|
      delete.action do |_global, options, _args|
        require_timestamp('s3 delete')
        handle_s3_options(options)

        cartage.s3.delete
      end
    end

    s3.desc 'Check plugin configuration'
    s3.long_desc <<-'DESC'
Verifies the configuration of the cartage-s3 section of the Cartage
configuration file.
    DESC
    s3.command 'check-config' do |check|
      check.hide!
      check.action do |_global, _options, _args|
        cartage.s3.check_config
      end
    end

    s3.plugin_version_command(Cartage::S3)
  end
end
