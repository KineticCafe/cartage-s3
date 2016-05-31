### 2.0 / 2016-05-31

*   Rewrote for compatibility with cartage 2.0.

*   3 major enhancements

    *   Configuration now supports multiple destinations. Old cartage-s3
        configurations will continue to work and be accessible under the
        destination name +default+. An error will be raised if there is an
        explicit +default+ destination combined with this implicit +default+
        destination.

    *   The <tt>s3 put</tt> command (<tt>cartage s3 put</tt>) does *not* cause
        the build of a package, but will only upload a build file. This
        requires that a timestamp be provided either on the command-line or
        through a configuration file.

            cartage --timestamp=<TIMESTAMP> s3 put

    *   Added <tt>s3 get</tt>, <tt>s3 list</tt>, and <tt>s3 delete</tt>
        commands.

### 1.0 / 2015-03-20

*   1 major enhancement

    *   Birthday!
