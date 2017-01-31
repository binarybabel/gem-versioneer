require File.dirname(File.expand_path(__FILE__)) + '/helpers'

module Versioneer
  class Git < Repo
    H = Helpers

    def initialize(file_within_repo, options=nil)
      super
      unless File.directory?(File.join(file_within_repo, '.git'))
        unless H.lines? `git ls-files #{file_within_repo} --error-unmatch #{H.cl_no_stderr}`
          raise InvalidRepoError, "Not inside a Git repo. (#{file_within_repo})"
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
      system 'git diff-index --quiet HEAD --'
      $?.exitstatus != 0
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
        if H.windows?
          `git tag --sort=-*creatordate`.split("\n").each do |tag|
            if tag.match(release_pattern)
              return tag
            end
          end
        else
          `git for-each-ref --sort='-*creatordate' --format '%(objecttype)=%(refname)'`.split("\n").each do |line|
            type, ref = line.chomp.split('=')
            ref_name = ref.split('/').last

            if type == 'tag' and ref_name.match(release_pattern)
              return ref_name
            end
          end
        end
        nil
      end
    end

    def first_ref
      cmd = 'git rev-list HEAD | tail -n 1'
      ref = `#{cmd} #{H.cl_no_stderr}`.chomp
      return nil if ref.empty?
      ref
    end
  end
end
