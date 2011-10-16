# encoding: utf-8
require 'test_helper'
require 'iconv'

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

      # TODO: Add missing specs.
    end

    describe '.parse_flags' do
      it 'should be defined' do
        assert_respond_to ::Klarna::API, :parse_flags
      end

      it 'should calculate value for one flag properly' do
        assert_equal 0, ::Klarna::API.parse_flags(:GOODS, :IS_SHIPMENT => false)
        assert_equal 8, ::Klarna::API.parse_flags(:GOODS, :IS_SHIPMENT => true)
      end

      it 'should calculate value for multiple flags properly using hash (bitwise OR - a.k.a sum)' do
        # Maybe overkill, but here we go... ;)

        # Uppercase
        assert_equal 0,   ::Klarna::API.parse_flags(:GOODS, :IS_SHIPMENT => false,  :IS_HANDLING => false,  :INC_VAT => false)
        assert_equal 8,   ::Klarna::API.parse_flags(:GOODS, :IS_SHIPMENT => true,   :IS_HANDLING => false,  :INC_VAT => false)
        assert_equal 16,  ::Klarna::API.parse_flags(:GOODS, :IS_SHIPMENT => false,  :IS_HANDLING => true,   :INC_VAT => false)
        assert_equal 32,  ::Klarna::API.parse_flags(:GOODS, :IS_SHIPMENT => false,  :IS_HANDLING => false,  :INC_VAT => true)
        assert_equal 24,  ::Klarna::API.parse_flags(:GOODS, :IS_SHIPMENT => true,   :IS_HANDLING => true,   :INC_VAT => false)
        assert_equal 48,  ::Klarna::API.parse_flags(:GOODS, :IS_SHIPMENT => false,  :IS_HANDLING => true,   :INC_VAT => true)
        assert_equal 56,  ::Klarna::API.parse_flags(:GOODS, :IS_SHIPMENT => true,   :IS_HANDLING => true,   :INC_VAT => true)

        # Lowercase (for readability)
        assert_equal 0,   ::Klarna::API.parse_flags(:goods, :is_shipment => false,  :is_handling => false,  :inc_vat => false)
        assert_equal 8,   ::Klarna::API.parse_flags(:goods, :is_shipment => true,   :is_handling => false,  :inc_vat => false)
        assert_equal 16,  ::Klarna::API.parse_flags(:goods, :is_shipment => false,  :is_handling => true,   :inc_vat => false)
        assert_equal 32,  ::Klarna::API.parse_flags(:goods, :is_shipment => false,  :is_handling => false,  :inc_vat => true)
        assert_equal 24,  ::Klarna::API.parse_flags(:goods, :is_shipment => true,   :is_handling => true,   :inc_vat => false)
        assert_equal 48,  ::Klarna::API.parse_flags(:goods, :is_shipment => false,  :is_handling => true,   :inc_vat => true)
        assert_equal 56,  ::Klarna::API.parse_flags(:goods, :is_shipment => true,   :is_handling => true,   :inc_vat => true)
      end
    end

    describe '.digest' do
      it 'should be defined' do
        assert_respond_to ::Klarna::API, :digest
      end

      it 'should calculate a valid digest secret for single value' do
        assert_equal "RvaNtGgJzI4FLDLz7dH4PIwWl3vYwR6qpx/whgCf7qkxj4+0prU0zXOAw9Jc\nSQw+iMqzgAMyjq79azKmp40uWg==", ::Klarna::API.digest("secret 123")
      end

      it 'should calculate a valid digest secret for an array of values' do
        assert_equal ::Klarna::API.digest("secret 1:secret 2:secret 3"), ::Klarna::API.digest("secret 1", "secret 2", "secret 3")
        assert_equal "yKMen8LPEev5yLYUTjFvJdWY/t2tTx3JsK2s1nIgwu3wFfrdu6Kzce1VcGfo\nC/6OXQtR6nGVntYhEP7KUmtADw==", ::Klarna::API.digest("secret 1", "secret 2", "secret 3")
      end
    end

    describe '.encode' do
      it 'should be defined' do
        assert_respond_to ::Klarna::API, :encode
      end

      it 'should encode a specified string from "UTF-8" to "ISO-8859-1" properly' do
        if RUBY_VERSION > '1.9'
          assert_equal 'ISO-8859-1', ::Klarna::API.encode("ÅÄÖ".force_encoding('UTF-8')).encoding.name
        else
          ::Iconv rescue require 'iconv'
          assert_equal 1, ::Klarna::API.encode("Ö").length # if it is UTF-8 String#length returns 2 bytes in Ruby < 1.9
        end
      end
    end

    describe '.decode' do
      it 'should be defined' do
        assert_respond_to ::Klarna::API, :decode
      end

      it 'should encode a specified string from "ISO-8859-1" to "UTF-8" properly' do
        if RUBY_VERSION > '1.9'
          assert_equal 'UTF-8', ::Klarna::API.decode("ÅÄÖ".force_encoding('ISO-8859-1')).encoding.name
        else
          ::Iconv rescue require 'iconv'
          assert_equal 2, ::Klarna::API.decode("Ö").length # if it is UTF-8 String#length returns 2 bytes in Ruby < 1.9
        end
      end
    end

  end

end