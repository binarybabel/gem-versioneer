module Versioneer
  begin
    GEM_VERSION = Config.new(::File.expand_path('../../../.versioneer.yml', __FILE__))
  rescue
    GEM_VERSION = '0.0.0'
  end
end
