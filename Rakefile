require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

task :default => :test

load 'changelog.rake'

task :relock do
  ENV['VERSIONEER_ENV'] = 'development'
  system './bin/versioneer unlock > /dev/null'
  system './bin/versioneer lock'
end

Rake::Task[:build].enhance [:relock] do
  system './bin/versioneer unlock > /dev/null'
end
