# encoding: utf-8
require 'test_helper'

describe ::Klarna::API do

  before do
    ::Klarna.setup do |c|
      c.store_id = VALID_STORE_ID
      c.store_secret = VALID_STORE_SECRET
    end
  end

  describe "Helpers" do

    describe '.client' do
      it 'should be defined' do
        assert_respond_to ::Klarna::API, :client
      end

      it 'should create a new ::Klarna RPC-API client with default settings' do
        client = ::Klarna::API.client
        assert_instance_of ::Klarna::API::Client, client
      end

      it 'should reuse existing ::Klarna RPC-API client instance if exists' do
        assert_equal ::Klarna::API.client, ::Klarna::API.client
      end

      it 'should be possible to force-re-initialize the client even though it is already initialized' do
        client_1 = ::Klarna::API.client(true)
        client_2 = ::Klarna::API.client(true)
        refute_equal client_1, client_2
      end
    end

    describe '.validated_kind' do
      it 'should be defined' do
        assert_respond_to ::Klarna::API, :validated_kind
      end

      it 'should only allow kinds: :country, :currency, :language, :pno_format, :address_format' do
        assert_equal :COUNTRIES, ::Klarna::API.validated_kind(:country)
        assert_equal :COUNTRIES, ::Klarna::API.validated_kind('country')

        assert_equal :CURRENCIES, ::Klarna::API.validated_kind(:currency)
        assert_equal :CURRENCIES, ::Klarna::API.validated_kind('currency')

        assert_equal :LANGUAGES, ::Klarna::API.validated_kind(:language)
        assert_equal :LANGUAGES, ::Klarna::API.validated_kind('language')

        assert_equal :PNO_FORMATS, ::Klarna::API.validated_kind(:pno_format)
        assert_equal :PNO_FORMATS, ::Klarna::API.validated_kind('pno_format')

        assert_equal :ADDRESS_FORMATS, ::Klarna::API.validated_kind(:address_format)
        assert_equal :ADDRESS_FORMATS, ::Klarna::API.validated_kind('address_format')

        assert_raises ::Klarna::API::KlarnaArgumentError do
          ::Klarna::API.validated_kind(:hello)
        end
      end
    end

    describe '.key_for' do
      it 'should be defined' do
        assert_respond_to ::Klarna::API, :key_for
      end

      it 'should return valid format KEY for a specified kind-key' do
        assert_equal :SE, ::Klarna::API.key_for(:pno_format, 'SE')
        assert_equal :SE, ::Klarna::API.key_for(:pno_format, :SE)
      end

      it 'should return valid format KEY for a specified kind-value' do
        assert_equal :SE, ::Klarna::API.key_for(:pno_format, '2')
        assert_equal :SE, ::Klarna::API.key_for(:pno_format, 2)
      end
    end

    describe '.id_for' do
      it 'should be defined' do
        assert_respond_to ::Klarna::API, :id_for
      end

      it 'should return valid format ID for a specified kind-key' do
        assert_equal 2, ::Klarna::API.id_for(:pno_format, 'SE')
        assert_equal 2, ::Klarna::API.id_for(:pno_format, :SE)
      end

      it 'should return valid format ID for a specified kind-value' do
        assert_equal 2, ::Klarna::API.id_for(:pno_format, '2')
        assert_equal 2, ::Klarna::API.id_for(:pno_format, 2)
      end
    end

    describe '.validate_arg' do
      it 'should be defined' do
        assert_respond_to ::Klarna::API, :validate_arg
      end

      # it 'should...'
    end

    describe '.digest' do
      it 'should be defined' do
        assert_respond_to ::Klarna::API, :digest
      end

      it 'should calculate a valid digest secret for one value' do
        # TODO
        # skip
      end

      it 'should calculate a valid digest secret for an array of values' do
        # TODO
        # skip
      end

      it 'should raise error if specified value is nor a string or an array' do
        # TODO
        # skip
      end
    end

    describe '.encode' do
      it 'should be defined' do
        assert_respond_to ::Klarna::API, :encode
      end

      it 'should encode a specified string from "UTF-8" to "iso-8859-1" properly' do
        # TODO
        # skip
      end
    end

  end

end