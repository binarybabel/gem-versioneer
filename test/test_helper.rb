def test_ci?
  ENV['TRAVIS_BUILD_NUMBER'] or ENV['APPVEYOR']
end

if test_ci?
  require 'simplecov'
  SimpleCov.start
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'versioneer'
require 'versioneer/helpers'
require 'minitest/autorun'
require 'fileutils'

require 'pry' unless test_ci?
