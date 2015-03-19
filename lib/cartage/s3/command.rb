require 'cartage/command'

class Cartage::S3::Command < Cartage::Command #:nodoc:
  def initialize(cartage)
    super(cartage, 's3')
    takes_commands(false)
    short_desc('Build a release package and upload to cloud storage.')

    @cartage = cartage
    @s3 = cartage.s3

    Cartage.common_build_options(options, cartage)

    options do |opts|
      opts.separator "Cartage S3 Options"
      opts.on(
        '-P', '--path PATH',
        'The bucket or path where the release package will be uploaded to.'
      ) { |b| @s3.path = b }
      opts.on(
        '-K', '--key-id AWS_ACCESS_KEY_ID',
        'The AWS S3 access key ID.'
      ) { |k| @s3.aws_access_key_id = k }
      opts.on(
        '-S', '--secret-key AWS_SECRET_ACCESS_KEY',
        'The AWS S3 secret access key.'
      ) { |s| @s3.aws_secret_access_key = s }
      opts.on(
        '-R', '--region REGION',
        'The AWS S3 region for uploading.'
      ) { |r| @s3.region = r }
    end
  end

  def perform(*)
    @cartage.pack
    @s3.upload
  end

  def with_plugins
    %w(s3)
  end
end
