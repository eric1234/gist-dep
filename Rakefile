require 'bundler/setup'
Bundler::GemHelper.install_tasks

require 'rake/testtask'

Rake::TestTask.new 'test:unit' do |t|
  t.test_files = FileList['test/unit/**/*_test.rb']
end

Rake::TestTask.new 'test:integration' do |t|
  t.test_files = FileList['test/integration/**/*_test.rb']
end

desc "Run all tests"
task :test => ['test:unit', 'test:integration']

task :default => :test
