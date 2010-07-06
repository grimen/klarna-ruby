# encoding: utf-8
require 'rubygems'

gem 'test-unit'
require 'test/unit'

require 'klarna'

require 'active_support/test_case'

Dir[File.join(File.dirname(__FILE__), *%w[support ** *.rb]).to_s].each { |f| require f }

ActiveSupport::TestCase.class_eval do
  include Klarna::AssertionsHelper
end