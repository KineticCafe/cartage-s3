# cartage s3 - Manage packages in remote storage

Cartage provides a repeatable means to create a package for a server-side
application that can be used in deployment with a configuration tool like
Ansible, Chef, Puppet, or Salt. This is the documentation for the `cartage s3`
command and plug-in for Cartage. All existing global Cartage options apply.

Commands to upload, download, list, or delete packages and package metadata to
remote storage.

## `s3` Options

__`-D`, `--destination DESTINATION`__

The name of the remote destination in the Cartage configuration file. Defaults
to `default`. If the destination does not exist in the configuration, an error
will be reported.

## `s3` Subcommands

### `s3 get`, `s3 download`

Downloads packages from remote storage. This command requires that a timestamp
is provided, either through a Cartage configuration file or through a global
--timestamp flag.

Any active plug-in supporting :build_package requests will provide a package
name to be downloaded. If the package file does not exist remotely, an error
will occur.

*__Options__*

__`--local-path PATH`__

The local path to write packages. Defaults to the current working directly
($PWD).

### `s3 ls`, `s3 list`

Lists packages in remote storage. Shows packages related to the current Cartage
project name.

*__Options__*

__`--all`__

Show all files in remote storage, not just the files related to the current
project.

### `s3 put`, `s3 upload`

Uploads packages and metadata from a previous build to remote storage. This
command requires that a timestamp is provided, either through a Cartage
configuration file or through the global --timestamp flag.

Any active plug-in supporting :build_package requests will provide a package
name to be uploaded. If the package file does not exist locally, an error will
occur.

### `s3 rm`, `s3 delete`

Removes packages from remote storage. This command requires that a timestamp is
provided, either through a Cartage configuration file or through a global
--timestamp flag.

Any active plug-in supporting :build_package requests will provide a package
name to be removed. If the package file does not exist remotely, an error will
occur.
