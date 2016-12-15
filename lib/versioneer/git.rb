require_relative 'helpers'

module Versioneer
  class Git < Base
    def initialize(file_within_repo, options=nil)
      super
      unless file_within_repo.is_a? Dir and Dir.join('.git').exist?
        unless H.lines? `git ls-files #{file_within_repo} --error-unmatch #{H.cl_no_stderr}`
          raise InvalidRepoError, 'Not a git repo.'
        end
      end
    end

    def release
      if (ref = release_ref)
        Gem::Version.new(ref.match(release_pattern)[1])
      else
        super
      end
    end

    def commits_since_release
      offset = 0
      unless (ref = release_ref)
        unless (ref = first_ref)
          return 0
        end
        offset = 1
      end
      H.num_of_lines(`git log #{ref}...HEAD --pretty=oneline #{H.cl_no_stderr}`) + offset
    end

    def filesystem_dirty?
      H.lines? `git status -s`
    end

    protected

    def release_ref
      cmd = 'git describe --abbrev=0 --tags'
      ref = `#{cmd} #{H.cl_no_stderr}`.chomp
      return nil if ref.empty?
      if ref.match(release_pattern)
        ref
      else
        # Iterate through tags in date order for first match.
        `git tag --sort=taggerdate`.split("\n").each do |tag|
          tag.chomp!
          if tag.match(release_pattern)
            return tag
          end
        end
      end
    end

    def first_ref
      cmd = 'git rev-list HEAD | tail -n 1'
      ref = `#{cmd} #{H.cl_no_stderr}`.chomp
      return nil if ref.empty?
      ref
    end

    private

    H = Helpers
  end
end
