require_relative 'helpers'
require_relative 'runtime_error'
require_relative 'missing_config_error'
require 'yaml'

module Versioneer
  class Config
    DEFAULT_TYPE = 'Git'
    DEFAULT_FILE = '.versioneer.yml'
    DEFAULT_LOCK = 'version.lock'

    def initialize(base_dir_or_config_file, repo_options=nil)
      base_dir_or_config_file = base_dir_or_config_file.to_s

      if Dir.exist?(base_dir_or_config_file)
        @config_base = base_dir_or_config_file
        @config_file = File.join(base_dir_or_config_file, DEFAULT_FILE)
        unless File.exist?(@config_file)
          raise MissingConfigError, "Versioneer config file does not exist. (#{@config_file})"
        end
      elsif File.exist?(base_dir_or_config_file)
        @config_file = base_dir_or_config_file
        @config_base = File.dirname(@config_file)
      else
        raise RuntimeError, "Versioneer base path does not exist. (#{base_dir_or_config_file})"
      end

      params = YAML.load_file(@config_file)
      raise RuntimeError, "Failed to parse YAML file. (#{@config_file})" unless params
      params = params.inject({}) { |x, (k, v)| x[k.to_sym] = v; x } # symbolize keys

      @lock_file = File.join(@config_base, params.delete(:lock_file) || DEFAULT_LOCK)
      @repo = nil
      @repo_type = (params.delete(:type) || DEFAULT_TYPE).capitalize.to_sym
      @repo_options = Hash.new().merge(params.to_h).merge(repo_options.to_h)
    end

    attr_reader :config_file, :lock_file

    def repo
      return @repo unless @repo.nil?
      @repo = case locked?
                when true
                  Bypass.new(@config_base, release: version)
                else
                  unless ::Versioneer.const_defined? @repo_type
                    raise RuntimeError, "Versioneer::#{@repo_type} is an unknown VCS type."
                  end

                  repo_class = ::Versioneer.const_get(@repo_type)
                  unless repo_class.superclass == ::Versioneer::Repo
                    raise RuntimeError, "Versioneer::#{@repo_type} is an invalid VCS type."
                  end

                  @repo = repo_class.new(@config_base, @repo_options)
              end
    end

    def locked?
      File.exist?(@lock_file)
    end

    def lock!(version=nil)
      @repo = nil
      version ||= repo.to_s
      raise RuntimeError, 'Cannot lock. Version neither given nor detected.' if version.to_s.empty?
      File.open(@lock_file, 'w') do |file|
        file.write(version)
      end
    end

    def unlock!
      @repo = nil
      if File.exist?(@lock_file)
        File.delete(@lock_file)
      end
    end

    def version
      if File.exist?(@lock_file)
        version = File.read(@lock_file)
        ::Gem::Version.new(version)
      else
        super
      end
    end

    def to_s
      version.to_s
    end

    def method_missing(name, *args, &block)
      if repo.respond_to? name
        repo.send(name, *args, &block)
      else
        super
      end
    end

    def respond_to?(name)
      return true if repo.respond_to? name
      super
    end
  end
end
