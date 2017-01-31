require File.dirname(File.expand_path(__FILE__)) + '/helpers'

module Versioneer
  class Bypass < Repo
    H = Helpers

    def initialize(file_within_repo, options=nil)
      raise InvalidRepoError if options[:invalid]
      super
      @commits_since_release = 0
      @filesystem_dirty = false
    end

    def release
      @release || super
    end

    def release=(v)
      v = ::Gem::Version.new(v) if v.is_a? String
      @release = v
    end

    attr_accessor :commits_since_release

    def filesystem_dirty?
      @filesystem_dirty
    end

    def filesystem_dirty=(v)
      @filesystem_dirty = v
    end
  end
end
