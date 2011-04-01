# encoding: utf-8
require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: Run all tests.'
task :default => :test

desc 'Test gem for klarna.'
Rake::TestTask.new(:test) do |test|
  test.libs << ['lib', 'test']
  test.pattern = 'test/**/*_test.rb'
end

desc 'Generate gem documentation for klarna.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Klarna/Kreditor Ruby API-wrapper Documentation'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.textile')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
