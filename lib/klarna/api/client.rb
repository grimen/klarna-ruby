# encoding: utf-8
require 'xmlrpc/client'

module Klarna
  module API
    class Client < ::XMLRPC::Client

      include ::Klarna::API::Methods

      attr_accessor :store_id, :store_secret, :mode, :use_ssl, :host, :port, :timeout

      def initialize(*args)
        self.store_id = args.shift || ::Klarna.store_id
        self.store_secret = args.shift || ::Klarna.store_secret

        if self.store_id.blank? || self.store_secret.blank?
          raise ::Klarna::API::KlarnaCredentialsError, "Both STORE_ID or STORE_SECRET must be set."
        end

        options = args.extract_options!
        self.mode = options.key?(:mode) ? options[:mode] : ::Klarna.mode
        self.use_ssl = options.key?(:use_ssl) ? options[:use_ssl] : ::Klarna.use_ssl
        self.timeout = options.key?(:timeout) ? options[:timeout] : 10 # seconds

        unless ::Klarna::API::END_POINT.keys.include?(self.mode)
          raise "No such mode: #{self.mode.inspect}. " <<
          "Valid modes: #{::Klarna::API::END_POINT.keys.collect(&:inspect).join(', ')}"
        end

        self.host = ::Klarna::API::END_POINT[self.mode][:host]
        self.port = options.key?(:port) ? options[:port] : ::Klarna::API::END_POINT[self.mode][:port]

        begin
          ::Klarna.log "Endpoint URI: %s" % self.endpoint_uri.inspect

          super(self.host, '/', self.port, nil, nil, nil, nil, self.use_ssl, self.timeout)

          self.http_header_extra ||= {}
          self.http_header_extra.merge!(self.content_type_headers)

          self.instance_variable_get(:@http).set_debug_output(::Klarna.logger) if ::Klarna.http_logging?
        rescue ::XMLRPC::FaultException => e
          raise ::Klarna::API::KlarnaServiceError.new(e.faultCode, e.faultString)
        end
      end

      def call_with_defaults(service_method, *args)
        args.collect! { |arg| arg.is_a?(String) ? ::Iconv.conv('utf-8', ::Klarna::API::PROTOCOL_ENCODING, arg) : arg }
        ::Klarna.log "Method: #{service_method}"
        ::Klarna.log "Params: %s" % self.add_meta_params(*args).inspect

        begin
          ::Klarna.log_result("Result: %s") do
            self.call(service_method, *self.add_meta_params(*args))
          end
        rescue ::XMLRPC::FaultException => e
          raise ::Klarna::API::KlarnaServiceError.new(e.faultCode, e.faultString)
        end
      end

      def use_ssl?
        self.use_ssl
      end

      def protocol
        self.use_ssl? ? 'https' : 'http'
      end

      def port
        @port || (self.use_ssl? ? 443 : ::Klarna::API::END_POINT[self.mode][:port])
      end

      def endpoint_uri
        "#{self.protocol}://#{self.host}:#{self.port}"
      end

      def environment=(value)
        @environment = value.to_s.downcase.to_sym rescue ::Klarna::DEFAULT_MODE
      end

      protected

        def content_type_headers
          {
            :'Accept-Charset' => ::Klarna::API::PROTOCOL_ENCODING,
            :'Content-Type' => "text/xml;charset=#{::Klarna::API::PROTOCOL_ENCODING}",
            :'Connection' => 'close',
            :'User-Agent' => 'ruby/xmlrpc' # Note: Default "User-Agent" gives 400-error.
          }.with_indifferent_access
        end

        # Ensure that the required client info params get sent with each Klarna API request.
        # Without these the Klarna API will get a service error response.
        #
        def add_meta_params(*args)
          args.unshift *[::Klarna::API::PROTOCOL_VERSION, ::XMLRPC::Client::USER_AGENT]
          args
        end

        def digest(*args)
          ::Klarna::API.digest(*[self.store_id, args, self.store_secret].flatten)
        end

    end
  end
end
