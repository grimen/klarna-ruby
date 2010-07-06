# encoding: utf-8
require 'rubygems'
require 'i18n'
require 'active_support'

module Klarna

  autoload :API,      'klarna/api'
  autoload :Models,   'klarna/models'
  autoload :VERSION,  'klarna/version'

  KlarnaConfigError = Class.new(::StandardError)

  DEFAULT_STORE_CONFIG_FILE = File.join(ENV['HOME'], '.kreditor.yml')
  VALID_COUNTRIES = [:SE, :NO, :FI, :DK]
  DEFAULT_COUNTRY = VALID_COUNTRIES.first
  DEFAULT_MODE = :test

  # Specifies running mode: +:test+ (alla actions gets virtual) or +:production+ (live)
  # Default: +:test+
  mattr_accessor :mode
  @@mode = :test

  mattr_accessor :use_ssl
  @@use_ssl = false

  # Country used to ensure that params sent to Klarna service is correct.
  # Default: +:SE+
  mattr_accessor :country
  @@country = DEFAULT_COUNTRY

  # Klarna e-store ID (a.k.a. "eid") used for Klarna API authentication.
  # Default: +nil+
  # NOTE: If +nil+, Klarna will look for credentials in file specified by +Devise.credentials_file+.
  mattr_accessor :store_id
  @@store_id = nil

  # Klarna e-store shared secret token used for Klarna API authentication.
  # Default: +nil+
  # NOTE: If +nil+, Klarna will look for credentials in file specified by +Devise.credentials_file+.
  mattr_accessor :store_secret
  @@store_secret = nil

  # Klarna e-store-specific pclasses (a.k.a. campaigns).
  # Default: +nil+
  #
  # NOTE:
  #   * Required for campaigns
  #   * This should maybe be initialized from database to make more dynamic (e.g. admin inteface).
  #
  mattr_accessor :pclasses
  @@pclasses = nil

  # Path to a YAML file containing API credentials - used only if +store_id+ and +store_secret+ are not set.
  # Default: +"~/.kreditor.yml"+
  mattr_accessor :store_config_file
  @@store_config_file = DEFAULT_STORE_CONFIG_FILE

  # The logger to use in log mode.
  # Default: +::Logger.new(::STDOUT)+
  mattr_accessor :logger
  @@logger = ::Logger.new(::STDOUT)

  # Sets if activity should be logged or not - for high-level debugging.
  # Default: +false+
  mattr_accessor :logging
  @@logging = false

  # Sets if Net::HTTP activity should be logged or not - for low-level debugging.
  # Default: +false+
  mattr_accessor :http_logging
  @@http_logging = false

  class << self

    # Configuration DSL helper method.
    #
    # == Usage/Example:
    #
    #   Klarna::Setup do |config|
    #     config.country = :SE
    #     # etc.
    #   end
    #
    def setup
      yield self
      self.load_credentials unless self.store_id || self.store_secret
    end

    # Logging helper for debugging purposes.
    #
    def log(message, level = :info)
      return unless self.logging?
      level = :info if level.blank?
      self.logger ||= ::Logger.new(::STDOUT)
      self.logger.send(level.to_sym, "[klarna:]  #{level.to_s.upcase}  #{message}")
    end

    # Logging helper for debugging "log return value"-cases.
    #
    def log_result(label, &block)
      result = block.call
      self.log label % result.inspect
      result
    end

    # Optional: Try to load credentials from a system file.
    #
    def load_credentials_file(force = false)
      begin
        store_config = File.open(self.store_config_file) { |file| YAML.load(file).with_indifferent_access }
        self.store_id     = store_config[self.mode][:store_id] if force || self.store_id.nil?
        self.store_secret = store_config[self.mode][:store_secret] if force || self.store_secret.nil?
        self.pclasses     = store_config[self.mode][:pclasses] if force || self.pclasses.nil?
      rescue
        raise KlarnaConfigError, "Could not load store details from: #{self.store_config_file.inspect}"
      end
    end

    def store_id=(value)
      @@store_id = value.to_i
    end

    def store_secret=(value)
      @@store_secret = value.to_s.strip
    end

    def country=(value)
      @@country = value.to_s.upcase.to_sym rescue DEFAULT_COUNTRY
    end

    def mode=(value)
      @@mode = value.to_s.downcase.to_sym rescue DEFAULT_MODE
    end

    alias :logging? :logging
    alias :http_logging? :http_logging
  end

end

# Load all I18n locales.
::I18n.load_path.unshift Dir[File.expand_path(File.join(File.dirname(__FILE__), *%w[klarna locales *.yml])).to_s]
