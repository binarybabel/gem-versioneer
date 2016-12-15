require 'test_helper'

class VersioneerTest < Minitest::Test
  def setup
  end

  def teardown
  end

  def test_bump
    k = Versioneer::Base
    assert_equal k.bump(Gem::Version.new('0.0.0'), :patch).to_s, '0.0.1'
    assert_equal k.bump(Gem::Version.new('0.0'), :patch).to_s, '0.0.1'
    assert_equal k.bump(Gem::Version.new('0.0.0'), :minor).to_s, '0.1'
    assert_equal k.bump(Gem::Version.new('0.0.1'), :minor).to_s, '0.1'
    assert_equal k.bump(Gem::Version.new('0.0.1'), :minor, 'pre1').to_s, '0.1.pre1'
  end
end
