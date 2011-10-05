# -*- encoding: utf-8 -*-
$:.unshift File.dirname(__FILE__)

require 'mocha' # REVIEW: Had to place this before MiniTest - if placed after ~100 failing specs. :S
require 'minitest/unit'
require 'minitest/spec'
require 'minitest/pride'
require 'minitest/autorun'

require 'klarna'

Dir[File.join(File.dirname(__FILE__), *%w[support ** *.rb]).to_s].each { |f| require f }

MiniTest::Unit::TestCase.class_eval do
  include Klarna::AssertionsHelper
end

VALID_STORE_ID      = ENV['KLARNA_ESTORE_ID'].presence || 2 # NOTE: This estore-id used to work for testing until 2011.09.
VALID_STORE_SECRET  = ENV['KLARNA_ESTORE_SECRET'].presence || 'lakrits' # NOTE: This estore-secret used to work for testing until 2011.09.
VALID_COUNTRY       = :SE

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
    c.store_id = VALID_STORE_ID.to_i
    c.store_secret = VALID_STORE_SECRET
    c.country = VALID_COUNTRY
    c.mode = :production # NOTE: Actually not production unless test-mode is disabled in the Klarna admin pages.
    c.http_logging = (ENV['KLARNA_DEBUG'].to_s =~ /(true|1)/) || false
  end
end

def digest(*args)
  Klarna::API::Client.digest(*args)
end
