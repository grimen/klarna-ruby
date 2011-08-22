# encoding: utf-8
# require 'rubygems'
# require 'bundler'
# Bundler.require
require 'i18n'
require 'active_support/all'

module Klarna

  autoload :API,      'klarna/api'
  autoload :VERSION,  'klarna/version'

  module API
    autoload :Client,     'klarna/api/client'
    autoload :Constants,  'klarna/api/constants'
    autoload :Errors,     'klarna/api/errors'

    module Methods
      autoload :Standard,         'klarna/api/methods/standard'
      autoload :Invoicing,        'klarna/api/methods/invoicing'
      autoload :Reservation,      'klarna/api/methods/reservation'
      autoload :CostCalculations, 'klarna/api/methods/cost_calculations'
    end
  end

  class KlarnaConfigError < ::StandardError
  end

  DEFAULT_STORE_CONFIG_FILE = File.join(ENV['HOME'], '.klarna.yml') unless defined?(::Klarna::DEFAULT_STORE_CONFIG_FILE)
  VALID_COUNTRIES = [:SE, :NO, :FI, :DK] unless defined?(::Klarna::VALID_COUNTRIES)
  DEFAULT_COUNTRY = VALID_COUNTRIES.first unless defined?(::Klarna::DEFAULT_COUNTRY)
  DEFAULT_MODE = :test unless defined?(::Klarna::DEFAULT_MODE)

  # Specifies running mode: +:test+ (alla actions gets virtual) or +:production+ (live)
  # Default: +:test+
  mattr_accessor :mode
  @@mode = :test

  # Country used to ensure that params sent to Klarna service is correct.
  # Default: +:SE+
  mattr_accessor :country
  @@country = ::Klarna::DEFAULT_COUNTRY

  # Klarna e-store ID (a.k.a. "eid") used for Klarna API authentication.
  # Default: +nil+
  # NOTE: If +nil+, Klarna will look for credentials in file specified by +Devise.store_config_file+.
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
  mattr_accessor :store_pclasses
  @@store_pclasses = nil

  # Path to a YAML file containing API credentials - used only if +store_id+ and +store_secret+ are not set.
  # Default: +"~/.klarna.yml"+
  mattr_accessor :store_config_file
  @@store_config_file = ::Klarna::DEFAULT_STORE_CONFIG_FILE

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
      self.load_credentials_from_file unless self.store_id || self.store_secret
    end
    alias :configure :setup

    # Reset to defaults - mostly usable in specs.
    #
    def reset!
      self.mode = ::Klarna::DEFAULT_MODE
      self.country = ::Klarna::DEFAULT_COUNTRY
      self.store_id = nil
      self.store_secret = nil
      self.store_pclasses = nil
      self.store_config_file = ::Klarna::DEFAULT_STORE_CONFIG_FILE
      self.logger = ::Logger.new(::STDOUT)
      self.logging = false
      self.http_logging = false
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
    def load_credentials_from_file(force = false)
      begin
        store_config = File.open(self.store_config_file) { |file| YAML.load(file).with_indifferent_access }
        self.store_id = store_config[self.mode][:store_id] if force || self.store_id.nil?
        self.store_secret = store_config[self.mode][:store_secret] if force || self.store_secret.nil?
        self.store_pclasses = store_config[self.mode][:store_pclasses] if force || self.store_pclasses.nil?
      rescue
        raise KlarnaConfigError, "Could not load store details from: #{self.store_config_file.inspect}"
      end
    end

    def store_id=(value)
      @@store_id = value ? value.to_i : value
    end

    def store_secret=(value)
      @@store_secret = value ? value.to_s.strip : value
    end

    def country=(value)
      @@country = value.to_s.upcase.to_sym rescue ::Klarna::DEFAULT_COUNTRY
    end

    def mode=(value)
      @@mode = value.to_s.downcase.to_sym rescue ::Klarna::DEFAULT_MODE
    end

    def valid_countries
      ::Klarna::VALID_COUNTRIES
    end

    def default_country
      ::Klarna::DEFAULT_COUNTRY
    end

    alias :logging? :logging
    alias :http_logging? :http_logging
  end

end
