# encoding: utf-8
require 'test_helper'

describe Klarna::API::Methods::Reservation do

   # TODO: Mock responses using VCR.

  before do
    valid_credentials!
    @client = Klarna::API::Client.new

    @protocol_version = ::Klarna::API::PROTOCOL_VERSION.to_s
    @user_agent = ::XMLRPC::Client::USER_AGENT.to_s

    expose_protected_methods_in @client.class
  end

  # Spec: http://integration.klarna.com/en/api/advanced-integration/functions/reserveamount
  describe '#reserve_amount' do
    it 'should be defined' do
      assert_respond_to @client, :reserve_amount
    end
  end

  # Spec: http://integration.klarna.com/en/api/advanced-integration/functions/activatereservation
  describe '#activate_reservation' do
    it 'should be defined' do
      assert_respond_to @client, :activate_reservation
    end
  end

  # Spec: http://integration.klarna.com/en/api/advanced-integration/functions/cancelreservation
  describe '#cancel_reservation' do
    it 'should be defined' do
      assert_respond_to @client, :cancel_reservation
    end
  end

  describe '#split_reservation' do
    it 'should be defined' do
      assert_respond_to @client, :split_reservation
    end
  end

  # Spec: http://integration.klarna.com/en/api/advanced-integration/functions/changereservation
  describe '#change_reservation' do
    it 'should be defined' do
      assert_respond_to @client, :change_reservation
    end
  end

  # Spec: http://integration.klarna.com/en/api/advanced-integration/functions/reserveocrnums
  describe '#reserve_ocr_numbers' do
    it 'should be defined' do
      assert_respond_to @client, :reserve_ocr_numbers
    end
  end

  # http://integration.klarna.com/en/api/advanced-integration/functions/mkaddress
  describe '#make_reservation_address' do
    it 'should be defined' do
      assert_respond_to @client, :make_reservation_address
    end
  end

end