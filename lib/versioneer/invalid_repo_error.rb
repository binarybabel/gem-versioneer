require File.dirname(File.expand_path(__FILE__)) + '/runtime_error'

module Versioneer
  class InvalidRepoError < RuntimeError

  end
end
