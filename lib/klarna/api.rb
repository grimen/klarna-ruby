# encoding: utf-8
require 'iconv'
require 'digest/md5'
require 'xmlrpc/base64'

module Klarna
  module API

    autoload :Client,     'klarna/api/client'

    autoload :Constants,  'klarna/api/constants'
    autoload :Errors,     'klarna/api/errors'
    autoload :Methods,    'klarna/api/methods'

    autoload :PClasses,   'klarna/api/p_classes'

    # == Reference:
    #
    #   * http://integration.klarna.com/api-functions
    #
    # == Note:
    #
    #   All input data strings should be coded in accordance with ISO-8859-1.
    #
    #   This implementation is not 1-to-1 implementation of the Klarna API functions.
    #   The methods are refactored/cleaned up to meet Ruby code standards; avoid
    #   unessecary code-repetition and spaghetti-code like the other implementations.
    #   Same functionality can be achieved though; see the RDocs.
    #
    #   To obtain pclasses - or download the pclasses file:
    #
    #     1. Log in to Kreditor Online.
    #     2. Click on "Display store"
    #     3. Click on "Click here to view campaigns".
    #
    #   ...or use the API-method +::Klarna::API.get_pclasses+.
    #

    include Constants
    include Errors

    class << self

      # Re-use or (re-)initialize a new Klarna XML-RPC API client.
      #
      def client(force_new = false)
        begin
          @@client = ::Klarna::API::Client.new if force_new || @@client.nil?
        rescue
          ::Klarna.log e, :error
        end
      end

      def currency_id_for(currency)
        begin
          currency.is_a?(Fixnum) ? currency : ::Klarna::API::Currencies.const_get(currency.to_s.upcase.to_sym)
        rescue
          raise "Invalid currency: #{currency.inspect}"
        end
      end

      def country_id_for(country)
        begin
          country.is_a?(Fixnum) ? country : ::Klarna::API::Countries.const_get(country.to_s.upcase.to_sym)
        rescue
          raise "Invalid country: #{country.inspect}"
        end
      end

      def language_id_for(language)
        begin
          language.is_a?(Fixnum) ? language : ::Klarna::API::Languages.const_get(language.to_s.upcase.to_sym)
        rescue
          raise "Invalid language: #{lang.inspect}"
        end
      end

      def digest(*args)
        string = args.join(':')
        iso_value = self.encode(string)
        hex_md5_digest = [*::Digest::MD5.hexdigest(iso_value)].pack('H*')
        base64_digest = ::XMLRPC::Base64.encode(hex_md5_digest).strip
      end

      def encode(string, from_encoding = 'utf-8')
        ::Iconv.conv(::Klarna::API::PROTOCOL_ENCODING, from_encoding, string)
      end

    end

  end
end