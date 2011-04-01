# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'klarna/version'

Gem::Specification.new do |s|
  s.name        = "klarna"
  s.version     = Klarna::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jonas Grimfelt"]
  s.email       = ["jonas@merchii.com"]
  s.homepage    = "http://github.com/merchii/#{s.name}"
  s.summary     = %{A Ruby wrapper for Klarna/Kreditor XML-RPC API.}
  s.description = s.summary

  s.add_dependency 'activesupport'
  s.add_dependency 'i18n'

  s.add_development_dependency 'minitest'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'turn'
  s.add_development_dependency 'sinatra'
  s.add_development_dependency 'sinatra-mapping'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
end