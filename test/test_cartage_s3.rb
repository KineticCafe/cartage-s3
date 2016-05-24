# frozen_string_literal: true
require 'minitest_config'

describe 'Cartage::S3' do
  let(:path) { 'target-path' }
  let(:credentials) {
    {
      provider: 'aws'
    }
  }
  let(:destination) {
    {
      path: path,
      credentials: credentials
    }
  }
  let(:s3_config) {
    {
      destinations: {
        default: destination
      }
    }
  }
  let(:config_hash) {
    {
      root_path: '/a/b/c',
      name: 'test',
      timestamp: 'value',
      plugins: {
        s3: s3_config
      }
    }
  }
  let(:config) { Cartage::Config.new(config_hash) }
  let(:cartage) { Cartage.new(config) }
  let(:subject) { cartage.s3 }

  def self.it_verifies_configuration(focus: false, &block)
    self.focus if focus
    it 'fails if there is no destination with the given name' do
      s3_config[:destination] = 'foo'
      ex = assert_raises RuntimeError do
        instance_exec(&block)
      end
      assert_equal 'No destination foo present', ex.message
    end

    self.focus if focus
    it 'fails if there are no destinations present' do
      s3_config[:destinations] = {}

      ex = assert_raises ArgumentError do
        instance_exec(&block)
      end
      assert_equal 'No destinations present', ex.message
    end

    self.focus if focus
    it 'warns if a destination is missing some configuration' do
      s3_config[:destinations][:foo] = {}

      error = <<-EOS
Destination foo invalid: No path present
Destination foo invalid: No provider present
      EOS

      assert_output nil, error do
        enable_warnings do
          instance_exec(&block)
        end
      end
    end
  end

  describe '#resolve_plugin_config!' do
    it 'errors with implicit and explicit destinations' do
      s3_config[:path] = 'alt-target-path'

      ex = assert_raises ArgumentError do
        cartage
      end

      assert_match(/implicit and explicit/, ex.message)
    end

    it 'requires path and credentials' do
      s3_config.delete(:destinations)
      s3_config[:path] = 'alt-target-path'

      ex = assert_raises ArgumentError do
        cartage
      end

      assert_match(/without both path and credentials/, ex.message)
    end

    it 'converts the implicit default into explicit' do
      s3_config.delete(:destinations)
      s3_config[:path] = path
      s3_config[:credentials] = credentials

      assert_equal s3_config[:destinations], cartage.config(for_plugin: :s3).
        dig(:destinations).to_hash
    end

    it 'fails on the destination missing a path' do
      destination.delete(:path)
      ex = assert_raises ArgumentError do
        subject
      end
      assert_equal 'Destination default invalid: No path present', ex.message
    end

    it 'fails on the destination missing a provider key' do
      credentials[:provider] = nil
      ex = assert_raises ArgumentError do
        subject
      end
      assert_equal 'Destination default invalid: No provider present', ex.message
    end
  end

  let(:expected_files) {
    [
      'test-value-release-metadata.json',
      'test-value.tar.bz2'
    ]
  }

  describe '#put' do
    it_verifies_configuration do
      instance_stub subject.class, :put_file, ->(*) {} do
        subject.put
      end
    end

    it '#put uploads the release metadata and packages' do
      expected_files.map! do |v|
        Pathname("/a/b/c/tmp/#{v}")
      end
      verifier = ->(v) { assert_equal Pathname(expected_files.shift), v }
      instance_stub subject.class, :put_file, verifier do
        subject.put
      end
    end
  end

  describe '#get' do
    it_verifies_configuration do
      instance_stub subject.class, :get_file, ->(*) {} do
        subject.get('.')
      end
    end

    it '#get downloads the release metadata and packages' do
      expected_files.map! do |v|
        Pathname("/a/b/c/tmp/#{v}")
      end
      verifier = ->(l, v) {
        assert_equal Pathname('.'), l
        assert_equal Pathname(expected_files.shift), v
      }
      instance_stub subject.class, :get_file, verifier do
        subject.get('.')
      end
    end
  end

  describe '#list' do
    it_verifies_configuration do
      instance_stub subject.class, :connection, -> { connection } do
        subject.list
      end
    end

    let(:files_test) {
      [
        'test-time1-release-metadata.json',
        'test-time1.tar.bz2',
        'test-time2-release-metadata.json',
        'test-time2.tar.bz2'
      ].map(&:dup)
    }

    let(:files_xyz) {
      [
        'xyz-time3-release-metadata.json',
        'xyz-time3.tar.bz2'
      ].map(&:dup)
    }

    let(:files_all) { files_test + files_xyz }

    let(:connection) {
      Object.new.tap do |c|
        files = files_all.map { |x|
          x.tap { x.define_singleton_method(:key, -> { self }) }
        }
        c.instance_variable_set(:@files, files)
        c.define_singleton_method :directories, -> { self }
        c.define_singleton_method :get, ->(*) { self }
        c.define_singleton_method :files, -> { @files }
      end
    }

    it '#list shows only files related to the package' do
      instance_stub subject.class, :connection, -> { connection } do
        assert_output "#{files_test.join("\n")}\n" do
          subject.list
        end
      end
    end

    it '#list(true) shows all files' do
      instance_stub subject.class, :connection, -> { connection } do
        assert_output "#{files_all.join("\n")}\n" do
          subject.list(true)
        end
      end
    end
  end

  describe '#delete' do
    it_verifies_configuration do
      instance_stub subject.class, :delete_file, ->(*) {} do
        subject.delete
      end
    end

    it '#delete removes the release metadata and packages' do
      expected_files.map! do |v|
        Pathname("/a/b/c/tmp/#{v}")
      end
      verifier = ->(v) { assert_equal Pathname(expected_files.shift), v }
      instance_stub subject.class, :delete_file, verifier do
        subject.delete
      end
    end
  end
end
