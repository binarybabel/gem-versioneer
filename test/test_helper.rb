def silence_warnings(&block)
  warn_level = $VERBOSE
  $VERBOSE = nil
  result = block.call
  $VERBOSE = warn_level
  result
end


def test_ci?
  ENV['TRAVIS_BUILD_NUMBER'] or ENV['APPVEYOR']
end

if test_ci?
  require 'simplecov'
  SimpleCov.start
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
# (Re)load instead of require to ensure coverage.
silence_warnings do
  load 'versioneer.rb'
  load 'versioneer/helpers.rb'
end

require 'minitest/autorun'
require 'fileutils'
require 'pry' unless test_ci?
