require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

task :default => :test

task :build do
  system './bin/versioneer unlock > /dev/null'
  system './bin/versioneer lock'
  puts '...'
  puts "Preparing to build Gem version #{`./bin/versioneer print`}..."
  puts 'Press Ctrl-C now to cancel'
  system 'sleep 5'
  puts '...'
  exec 'gem build versioneer.gemspec'
end
