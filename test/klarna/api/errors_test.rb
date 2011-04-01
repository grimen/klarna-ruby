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

    # TODO:
    # it 'should cast properly to hash value' do
    #   swap ::Klarna, :mode => :production do
    #     error = ::Klarna::API::Errors::KlarnaServiceError.new(7101, :no_such_subscription)
    #     # assert_equal ({:error_code => 7101, :error_message => "#{error_message} (#{error_key}): #{localized_error_message}"}), error.to_h
    #     assert_equal ({:error_code => 7101, :error_message => :no_such_subscription}), error.to_h
    #   end
    # end

    # TODO:
    # it 'should raise error with localized error message'
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