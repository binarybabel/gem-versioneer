require 'test_helper'

if test_ci?
  system 'git config --global user.name test'
  system 'git config --global user.email test@example.com'
end

class VersioneerGitTest < Minitest::Test
  H = Versioneer::Helpers

  def setup
    Dir.chdir(File.join(File.dirname(__FILE__), 'repo'))
    raise 'Unknown git directory detected in test/repo.' if File.directory?('.git')
    `git init && git add .keep && git config user.name test && git config user.email test@example.com`
    @git_created = true
    @q = Versioneer::Git.new(File.join(Dir.getwd, '.keep'), {
        :environment => 'development'
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
    system 'touch a && git add a'
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
    system 'touch a && git add a'
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

  def test_tag_search_non_alphabetical
    system 'git add .keep && git commit -m Initial'
    system 'git tag -am v0.2 v0.2'
    sleep(1) # ensure next tag has different timestamp

    system 'git commit --allow-empty -m Second'
    system 'git tag -am v0.4 v0.4'
    sleep(1)

    system 'git commit --allow-empty -m Third'
    system 'git tag -am v0.3 v0.3'
    sleep(1)

    system 'git commit --allow-empty -m Fourth'
    system 'git tag -am v0.1-rc1 v0.1-rc1'
    sleep(1)

    # v0.3 is the commit-recent tag matching the release pattern,
    #   but intentionally not the next alphabetically.
    assert_equal '0.3', @q.release.to_s
  end

  def test_tag_search_commit_order
    system 'git add .keep && git commit -m Initial'
    sleep(1) # ensure next tag has different timestamp
    system 'git commit --allow-empty -m Second'
    sleep(1)
    system 'git commit --allow-empty -m Third'
    sleep(1)
    system 'git commit --allow-empty -m Fourth'
    sleep(1)

    system 'git tag -am v0.1-rc1 v0.1-rc1'
    system 'git tag -a v0.2 HEAD~3 -m v0.2'
    system 'git tag -a v0.3 HEAD^ -m v0.3'
    system 'git tag -a v0.4 HEAD~2 -m v0.4'

    # v0.2 is the commit-recent tag matching the release pattern,
    #   but intentionally not the most recent tag added.
    assert_equal '0.3', @q.release.to_s
  end
end
