# encoding: utf-8
require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require File.join(File.dirname(__FILE__), 'lib', 'klarna', 'version')

# rdoc -m "README.rdoc" init.rb lib/ generators/ README.rdoc

# Gem managment tasks.
#
# == Generate gemspec, build & install locally:
#
#   rake gemspec
#   rake build
#   sudo rake install
#
# == Git tag & push to origin/master
#
#   rake release
#
# == Release to Gemcutter.org:
#
#   rake gemcutter:release
#
begin
  gem 'jeweler'
  require 'jeweler'

  Jeweler::Tasks.new do |spec|
    spec.name         = "klarna"
    spec.version      = ::Klarna::VERSION
    spec.summary      = %{A Ruby wrapper for Klarna/Kreditor XML-RPC API.}
    spec.description  = spec.summary
    spec.homepage     = "http://github.com/grimen/#{spec.name}"
    spec.authors      = ["Jonas Grimfelt"]
    spec.email        = "grimen@gmail.com"

    spec.files = FileList["[A-Z]*", File.join(*%w[{lib} ** *]).to_s, "init.rb"]
    spec.extra_rdoc_files = FileList["[A-Z]*"] - %w[Rakefile]

    spec.add_dependency 'activesupport', '>= 2.3.0'
    spec.add_development_dependency 'sinatra'
  end

  # Jeweler::GemcutterTasks.new   # Disabled for now.
rescue LoadError
  puts "Jeweler - or one of its dependencies - is not available. " <<
  "Install it with: sudo gem install jeweler -s http://gemcutter.org"
end

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the cells plugin.'
Rake::TestTask.new(:test) do |test|
  test.libs << ['lib', 'test']
  test.pattern = 'test/**/*_test.rb'
end

desc 'Generate documentation for the cells plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Klarna/Kreditor Ruby API-wrapper Documentation'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
