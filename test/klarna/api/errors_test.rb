# encoding: utf-8
require 'test_helper'

describe Klarna::API::Errors do

  describe Klarna::API::Errors::KlarnaStandardError do
    it 'should be defined' do
      assert defined?(::Klarna::API::Errors::KlarnaStandardError)
    end
  end

  describe Klarna::API::Errors::KlarnaCredentialsError do
    it 'should be defined' do
      assert defined?(::Klarna::API::Errors::KlarnaCredentialsError)
    end
  end

  describe Klarna::API::Errors::KlarnaServiceError do
    it 'should be defined' do
      assert defined?(::Klarna::API::Errors::KlarnaServiceError)
    end
  end

  describe ".error_message" do
    it "should return correct error key from a ID" do
      assert_equal :no_such_subscription, ::Klarna::API::Errors.error_message(7101)
    end

    it "should return correct error key from a key" do
      assert_equal :no_such_subscription, ::Klarna::API::Errors.error_message(:no_such_subscription)
    end
  end

end