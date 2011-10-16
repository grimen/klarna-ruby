# encoding: utf-8
require 'digest/sha2'
require 'xmlrpc/base64'

require 'klarna/api/constants'
require 'klarna/api/errors'

module Klarna
  module API

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

    include ::Klarna::API::Constants
    include ::Klarna::API::Errors

    @@client = nil

    class << self

      # Re-use or (re-)initialize a new Klarna XML-RPC API client.
      #
      def client(force_new = false)
        begin
          if force_new || @@client.nil?
            @@client = ::Klarna::API::Client.new
          end
        rescue => e
          ::Klarna.log e, :error
        end
        @@client
      end

      def key_for(kind, value)
        begin
          kind = validated_kind(kind)
        rescue => e
          raise e
        end

        begin
          is_correct_format = !(value.to_s =~ /^\d+$/)
          constants = ::Klarna::API.const_get(kind)
          key = is_correct_format ? value : constants.invert[value.to_i] # BUG: Should lookup the value's key.
        rescue
          raise ::Klarna::API::KlarnaArgumentError, "Invalid '#{kind}': #{value.inspect}"
        end

        key ? key.to_sym : nil
      end

      def id_for(kind, value)
        begin
          kind = validated_kind(kind)
        rescue => e
          raise e
        end

        begin
          is_correct_format = (value.to_s =~ /^\d+$/)
          constants = ::Klarna::API.const_get(kind)
          id = is_correct_format ? value.to_i : constants[value.to_s.upcase.to_sym]
        rescue
          raise ::Klarna::API::KlarnaArgumentError, "Invalid '#{kind}': #{value.inspect}"
        end

        id ? id.to_i : nil
      end

      # Validate if specified +kind+ is a valid constant.
      #
      def validated_kind(kind)
        valid_kinds = [:country, :currency, :language, :pno_format, :address_format, :shipment_type, :pclass, :mobile, :invoice, :goods, :monthly_cost]
        valid_kinds.collect! do |valid_kind|
          [valid_kind.to_s.singularize.to_sym, valid_kind.to_s.pluralize.to_sym]
        end
        valid_kinds.flatten!
        kind = kind.to_s.pluralize.to_sym

        unless kind.is_a?(String) || kind.is_a?(Symbol)
          raise ::Klarna::API::KlarnaArgumentError, "Not a valid kind: #{kind.inspect}. Expects a symbol or a string: #{valid_kinds.join(', ')}"
        end

        unless valid_kinds.include?(kind.to_s.downcase.to_sym)
          raise ::Klarna::API::KlarnaArgumentError, "Not a valid kind: #{kind.inspect}. Valid kinds: #{valid_kinds.join(', ')}"
        end

        kind.to_s.upcase.to_sym
      end

      # Parse, validate, and cast a method argument before RPC-call.
      #
      def validate_arg(value, cast_to, format_expression, strip_expression = nil, &block)
        raise ::Klarna::API::KlarnaArgumentError,
          "Argument cast_to should be Symbol, but was #{cast_to.class.name}." unless cast_to.is_a?(Symbol)
        raise ::Klarna::API::KlarnaArgumentError,
          "Argument regexp should be Regexp, but was #{format_expression.class.name}." unless format_expression.is_a?(Regexp)
        raise ::Klarna::API::KlarnaArgumentError,
          "Argument strip should be Regexp, but was #{strip_expression.class.name}." unless strip_expression.is_a?(Regexp)

        value = value.to_s.gsub(strip_expression, '') if strip_expression

        unless value.to_s =~ format_expression
          raise ::Klarna::API::KlarnaArgumentError, "Invalid argument: #{value.inspect}. Expected format: #{format_expression.inspect}"
        end

        # Pass value to block - for type casting, etc. - if given.
        value = block.call(value) if block_given?

        value.tap do |v|
          case cast_to
          when :string then v.to_s
          when :integer then v.to_i
          when :decimal then v.to_f # number of decimals?
          when :date then v # TODO
          else
            raise ::Klarna::API::KlarnaArgumentError, "Invalid cast_to value: #{cast_to.inspect}. "
          end
        end
      end

      def parse_flags(constant_name, flags)
        if flags.is_a?(Hash)
          flags = flags.sum do |k, v|
            v ? ::Klarna::API.const_get(constant_name.to_s.upcase.to_sym)[k.to_s.upcase.to_sym] : 0
          end
        end
        flags.to_i
      end

      def digest(*args)
        string = args.join(':')
        iso_value = self.encode(string)


        hex_md5_digest = [*::Digest::MD5.hexdigest(iso_value)].pack('H*')
        base64_digest = ::XMLRPC::Base64.encode(hex_md5_digest).strip
        hex_sha512_digest = [*Digest::SHA512.hexdigest(iso_value)].pack('H*')
        base64_digest = ::XMLRPC::Base64.encode(hex_sha512_digest).strip
      end

      def encode(string, from_encoding = 'utf-8')
        if string.respond_to?(:encode)
          string.encode(::Klarna::API::PROTOCOL_ENCODING, from_encoding)
        else
          ::Iconv.conv(::Klarna::API::PROTOCOL_ENCODING, from_encoding, string)
        end
      end

      def decode(string, from_encoding = ::Klarna::API::PROTOCOL_ENCODING)
        if string.respond_to?(:encode)
          string.encode('utf-8', from_encoding)
        else
          ::Iconv rescue require 'iconv'
          ::Iconv.conv(from_encoding, ::Klarna::API::PROTOCOL_ENCODING, string)
        end
      end

    end

  end
end