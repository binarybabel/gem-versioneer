require 'test_helper'
require 'yaml'

class VersioneerConfigTest < Minitest::Test
  H = Versioneer::Helpers
  DEFAULT_FILE = Versioneer::Config::DEFAULT_FILE
  OTHER_FILE = 'versioneer-other.yml'
  LOCK_FILE = Versioneer::Config::DEFAULT_LOCK

  def setup
    Dir.chdir(File.join(File.dirname(__FILE__), 'repo'))
  end

  def teardown
    FileUtils.rm_f [DEFAULT_FILE, OTHER_FILE, LOCK_FILE]
  end

  def configure(data, index=1)
    data ||= Hash.new
    data[:type] ||= 'Bypass'
    yaml = data.to_yaml
    filename = [DEFAULT_FILE, OTHER_FILE].fetch(index-1)
    File.open(filename, 'w') do |file|
      file.write(yaml)
    end
  end

  def build
    @q = Versioneer::Config.new(File.join(Dir.getwd))
  end

  def test_invalid_dir
    assert_raises Versioneer::RuntimeError do
      Versioneer::Config.new(File.join(File.dirname(__FILE__), 'no-repo'))
    end
  end

  def test_missing_config
    assert_raises Versioneer::MissingConfigError do
      build
    end
  end

  def test_invalid_type
    configure(type: 'anothervcs')
    assert_raises Versioneer::RuntimeError do
      build.version
    end
  end

  def test_release
    configure(release: '1.0')
    assert_equal '1.0', build.release.to_s
  end

  def test_version_lock
    configure(release: '1.1')
    build
    assert_equal '1.1', @q.version.to_s
    @q.lock!
    @q.commits_since_release = 1
    assert_equal '1.1', @q.version.to_s
    @q.unlock!
    @q.commits_since_release = 1
    refute_equal '1.1', @q.version.to_s
  end

  def test_version_lock_manual
    configure(release: '1.2')
    build
    assert_equal '1.2', @q.version.to_s
    @q.lock!('1.1')
    assert_equal '1.1', @q.version.to_s
  end

  def test_version_lock_invalid_repo
    configure(release: '1.3', invalid: true)
    assert_raises Versioneer::InvalidRepoError do
      build.version
    end
    configure(release: '1.3')
    build.lock!
    configure(release: '1.4', invalid: true)
    assert_equal '1.3', build.version.to_s
  end

  def test_other_version_file
    configure({release: '2.0'}, 2)
    @q = Versioneer::Config.new(File.join(File.dirname(__FILE__), 'repo', OTHER_FILE))
    assert_equal '2.0', @q.version.to_s
  end
end
