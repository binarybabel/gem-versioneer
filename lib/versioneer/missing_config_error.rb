require File.dirname(File.expand_path(__FILE__)) + '/runtime_error'

module Versioneer
  class MissingConfigError < RuntimeError

  end
end
