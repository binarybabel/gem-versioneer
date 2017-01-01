require 'test_helper'

if test_ci?
  system 'git config --global user.name test'
  system 'git config --global user.email test@example.com'
end

class VersioneerGitTest < Minitest::Test
  H = Versioneer::Helpers

  def setup
    Dir.chdir(File.join(File.dirname(__FILE__), 'repo'))
    raise 'Unknown git directory detected in test/repo.' if Dir.exist?('.git')
    `git init && git add .keep && git config user.name test && git config user.email test@example.com`
    @git_created = true
    @q = Versioneer::Git.new(File.join(Dir.getwd, '.keep'), {
        environment: 'development'
    })
  end

  def teardown
    FileUtils.rmtree '.git' if @git_created
    @git_created = false
    FileUtils.rm_f %w{a b c}
  end

  def no_rc_test(&block)
    x = @q.prereleases.pop
    block.call(@q)
    @q.prereleases.push x
  end

  def test_not_a_git_repo
    assert_raises Versioneer::InvalidRepoError do
      @q.class.new('/tmp/versioneer')
    end
  end

  def test_no_commits
    assert_equal 0, @q.commits_since_release
    assert @q.filesystem_dirty?
    assert_equal '0.0', @q.release.to_s
    assert_equal '0.1.alpha1', @q.version.to_s
  end

  def test_one_commit_no_tags
    system 'git add .keep && git commit -m Initial'
    assert_equal 1, @q.commits_since_release
    refute @q.filesystem_dirty?
    assert_equal '0.0', @q.release.to_s
    assert_equal '0.1.beta1', @q.version.to_s
    # Production
    @q.environment = 'production'
    assert_equal '0.1.rc1', @q.version.to_s
    no_rc_test do
      assert_equal '0.0.1', @q.version.to_s
    end
  end

  def test_two_commits_no_tags
    system 'git add .keep && git commit -m Initial'
    system 'git commit --allow-empty -m Second'
    assert_equal 2, @q.commits_since_release
    refute @q.filesystem_dirty?
    assert_equal '0.0', @q.release.to_s
    assert_equal '0.1.beta2', @q.version.to_s
    # Become dirty
    system 'touch a'
    assert @q.filesystem_dirty?
    assert_equal '0.1.alpha3', @q.version.to_s
    # Production
    @q.environment = 'production'
    assert_equal '0.1.rc2', @q.version.to_s
    no_rc_test do
      assert_equal '0.0.2', @q.version.to_s
    end
  end

  def test_one_tag
    system 'git add .keep && git commit -m Initial'
    system 'git tag -am v0.5 v0.5'
    assert_equal 0, @q.commits_since_release
    refute @q.filesystem_dirty?
    assert_equal '0.5', @q.release.to_s
    assert_equal '0.5', @q.version.to_s
    # Become dirty
    system 'touch a'
    assert_equal '0.6.alpha1', @q.version.to_s
    # Production
    @q.environment = 'production'
    assert_equal '0.5', @q.version.to_s
    no_rc_test do
      assert_equal '0.5', @q.version.to_s
    end
  end

  def test_one_tag_one_commit
    system 'git add .keep && git commit -m Initial'
    system 'git tag -am v0.5.3 v0.5.3'
    system 'git commit --allow-empty -m Second'
    assert_equal 1, @q.commits_since_release
    refute @q.filesystem_dirty?
    assert_equal '0.5.3', @q.release.to_s
    assert_equal '0.6.beta1', @q.version.to_s
    # Production
    @q.environment = 'production'
    assert_equal '0.6.rc1', @q.version.to_s
    no_rc_test do
      assert_equal '0.5.4', @q.version.to_s
    end
  end

  def test_two_tags
    system 'git add .keep && git commit -m Initial'
    system 'git tag -am v0.5 v0.5'
    system 'git commit --allow-empty -m Second'
    system 'git tag -am v0.6.1 v0.6.1'
    assert_equal '0.6.1', @q.release.to_s
    # Production
    @q.environment = 'production'
    assert_equal '0.6.1', @q.release.to_s
    no_rc_test do
      assert_equal '0.6.1', @q.version.to_s
    end
  end

  unless ENV['TRAVIS_BUILD_NUMBER']
    # Travis is packaged with outdated version of git
    #   which does not support sorting tags.
    # TODO: Update git in CI or find better solution.
    def test_prerelease_tags
      system 'git add .keep && git commit -m Initial'
      system 'git tag -am v0.1 v0.1'
      system 'git commit --allow-empty -m Second'
      system 'git tag -am v0.2-rc1 v0.2-rc1'
      assert_equal '0.1', @q.release.to_s
    end
  end
end
