module Versioneer
  class Base
    def initialize(file_within_repo, options=nil)
      @file = file_within_repo
      @directory = File.dirname(@file)
      @environment = nil

      @bump_segment = :minor
      @prereleases = %w(alpha beta rc)
      @release_pattern = /^v?([0-9\.]+$)/
      @starting_release = Gem::Version.new('0.0')

      if options.is_a? Hash
        options.each do |k, v|
          send("#{k}=", v)
        end
      end
    end

    attr_accessor :starting_release,
                  :bump_segment,
                  :prereleases

    def environment
      @environment || ENV['RAILS_ENV'] || ENV['RACK_ENV'] || ENV['ENV'] || 'development'
    end

    attr_writer :environment

    def to_s
      version.to_s
    end

    def version
      prerelease = nil
      c = commits_since_release

      if environment == 'production'
        if bump_segment == :minor and prereleases[2].nil? and c > 0
          # Use commits as addition to patch level, instead of release candidate.
          return self.class.bump(release.release, :patch, nil, c)
        else
          prerelease = prereleases[2].to_s + c.to_s if c > 0
        end
      elsif filesystem_dirty?
        prerelease = prereleases[0].to_s + (c+1).to_s
      elsif c > 0
        prerelease = prereleases[1].to_s + c.to_s
      end

      if prerelease
        self.class.bump(release, bump_segment, prerelease)
      else
        release
      end
    end

    def release
      starting_release
    end

    attr_reader :release_pattern

    def release_pattern=(v)
      v = Regexp.new(v) if v.is_a? String
      @release_pattern = v
    end

    def commits_since_release
      0
    end

    def filesystem_dirty?
      true
    end

    def self.bump(version, bump_segment, prerelease_suffix=nil, bump_count=1)
      length = segment_to_i(bump_segment) + 1 unless bump_segment.nil?

      if version.prerelease? or bump_segment.nil?
        next_version = (version.release.segments + [prerelease_suffix]).compact.join('.')
      else
        next_version = version
        bump_count.times do
          segments = next_version.release.segments.slice(0, length)
          while segments.size < length + 1 # Version.bump strips last segment
            segments << 0
          end
          next_version = Gem::Version.new(segments.join('.')).bump
        end
        next_version = [next_version.to_s, prerelease_suffix].compact.join('.')
      end

      next_version
    end

    def self.segment_to_i(segment)
      [:major, :minor, :patch].index(segment)
    end
  end
end
