$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'versioneer'
require 'versioneer/helpers'

require 'minitest/autorun'
require 'fileutils'

def ci?
  ENV['TRAVIS_BUILD_NUMBER'] or ENV['APPVEYOR']
end

require 'pry' unless ci?
