%w{
  runtime_error
  invalid_repo_error
  missing_config_error
  repo
  config
  bypass
  git
  gem_version
}.each do |f|
  load "#{File.dirname(File.expand_path(__FILE__))}/versioneer/#{f}.rb"
end

module Versioneer
end
