# encoding: utf-8
require 'rubygems'
require 'bundler'
Bundler.require
$:.unshift File.dirname(__FILE__)

require 'mocha'
require 'minitest/unit'
require 'minitest/spec'
require 'minitest/pride'
require 'minitest/autorun'

require 'klarna'

Dir[File.join(File.dirname(__FILE__), *%w[support ** *.rb]).to_s].each { |f| require f }

MiniTest::Unit::TestCase.class_eval do
  include Klarna::AssertionsHelper
end

VALID_STORE_ID = 2
VALID_STORE_SECRET = 'lakrits'
VALID_COUNTRY = :SE

Klarna.store_config_file = File.join(File.dirname(__FILE__), 'fixtures', 'klarna.yml')

FIXTURES_FILES = {
  :persons => File.join(File.dirname(__FILE__), 'fixtures', 'api', 'persons.yml'),
  :companies => File.join(File.dirname(__FILE__), 'fixtures', 'api', 'companies.yml'),
  :stores => File.join(File.dirname(__FILE__), 'fixtures', 'api', 'stores.yml')
}

@@fixtures = {}
FIXTURES_FILES.each do |fixture_key, fixture_file_path|
  @@fixtures[fixture_key] = File.open(fixture_file_path) { |file| YAML.load(file).with_indifferent_access }
end
@@fixtures = @@fixtures.with_indifferent_access

def fixture(model)
  @@fixtures[model]
end

def valid_credentials!
  Klarna.setup do |c|
    c.store_id = VALID_STORE_ID
    c.store_secret = VALID_STORE_SECRET
    c.country = VALID_COUNTRY
    c.mode = :test
    c.http_logging = false
  end
end
