# encoding: utf-8
require 'test_helper'

describe Klarna::API::Methods::CostCalculations do

   # TODO: Mock responses.

  before do
    valid_credentials!
    @client = Klarna::API::Client.new

    @protocol_version = ::Klarna::API::PROTOCOL_VERSION.to_s
    @user_agent = ::XMLRPC::Client::USER_AGENT.to_s

    expose_protected_methods_in @client.class
  end

  # Spec: http://integration.klarna.com/en/api/monthly-cost-functions/functions/fetchpclasses
  describe '#fetch_pclasses' do
    it 'should be defined' do
      assert_respond_to @client, :fetch_pclasses
    end
  end

  # Spec: http://integration.klarna.com/en/api/monthly-cost-functions/functions/calcmonthlycost
  describe '#calculate_monthly_cost' do
    it 'should be defined' do
      assert_respond_to @client, :calculate_monthly_cost
    end
  end

  describe '#periodic_cost' do
    it 'should be defined' do
      assert_respond_to @client, :periodic_cost
    end
  end

  describe '#monthly_cost' do
    it 'should be defined' do
      assert_respond_to @client, :monthly_cost
    end
  end

  describe 'protected/private methods' do

    describe '#calculate_interest_cost' do
      it 'should be defined' do
        assert_respond_to @client, :calculate_interest_cost
      end
    end

    describe '#calculate_monthly_payment' do
      it 'should be defined' do
        assert_respond_to @client, :calculate_monthly_payment
      end
    end

    describe '#calculate_daily_rate' do
      it 'should be defined' do
        assert_respond_to @client, :calculate_daily_rate
      end
    end

    describe '#get_denominator' do
      it 'should be defined' do
        assert_respond_to @client, :get_denominator
      end
    end

    describe '#round_up' do
      it 'should be defined' do
        assert_respond_to @client, :round_up
      end
    end

  end

end