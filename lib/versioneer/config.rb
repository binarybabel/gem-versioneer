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
      if Dir.exist?(base_dir_or_config_file)
        @config_base = base_dir_or_config_file
        @config_file = File.join(base_dir_or_config_file, DEFAULT_FILE)
        unless File.exist?(@config_file)
          raise MissingConfigError, "#{self.class.name} file does not exist. (#{@config_file})"
        end
      elsif File.exist?(base_dir_or_config_file)
        @config_file = base_dir_or_config_file
        @config_base = File.dirname(@config_file)
      else
        raise RuntimeError, "#{self.class.name} file does not exist. (#{base_dir_or_config_file})"
      end

      params = YAML.load_file(@config_file)
      raise RuntimeError, "Failed to parse YAML file. (#{@config_file})" unless params
      params = params.inject({}){|x,(k,v)| x[k.to_sym] = v; x}

      repo_type = DEFAULT_TYPE
      if params[:type]
        repo_type = params.delete(:type).capitalize.to_sym
        raise RuntimeError, "Versioneer::#{repo_type} does not exist." unless ::Versioneer.const_defined? repo_type
      end

      repo_class = Versioneer.const_get(repo_type)
      raise RuntimeError, "Versioneer::#{repo_type} is invalid." unless repo_class.superclass == Versioneer::Repo

      @lock_file = File.join(@config_base, params.delete(:lock_file) || DEFAULT_LOCK)

      repo_options ||= Hash.new
      repo_options.merge!(params)

      begin
        @repo = repo_class.new(@config_base, repo_options)
      rescue RuntimeError => e
        if locked?
          @repo = Bypass.new(@config_base, release: version)
        else
          raise e
        end
      end
    end

    attr_reader :repo, :config_file, :lock_file

    def locked?
      File.exist?(@lock_file)
    end

    def lock!(version=nil)
      version ||= repo.to_s
      raise RuntimeError, 'Cannot lock. Version neither given nor detected.' if version.to_s.empty?
      File.open(@lock_file, 'w') do |file|
        file.write(version)
      end
    end

    def unlock!
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
      if @repo.respond_to? name
        @repo.send(name, *args, &block)
      else
        super
      end
    end
  end
end
