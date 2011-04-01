# encoding: utf-8
require 'test_helper'

describe Klarna do

  before do
    Klarna.reset!
    Klarna.store_config_file = File.join(File.dirname(__FILE__), 'fixtures', 'klarna.yml')
  end

  describe "Constants" do

    describe 'VALID_COUNTRIES' do
      it 'should be defined' do
        assert defined?(Klarna::VALID_COUNTRIES)
      end

      # TODO: Add additional countries
      it 'should have values: SE, NO, FI, DK' do
        assert_equal [:SE, :NO, :FI, :DK], Klarna::VALID_COUNTRIES
      end
    end

    describe 'DEFAULT_COUNTRY' do
      it 'should be defined' do
        assert defined?(Klarna::DEFAULT_COUNTRY)
      end

      it 'should have value: SE' do
        assert_equal :SE, Klarna::DEFAULT_COUNTRY
      end
    end

  end

  describe "Configuration" do

    describe '.mode' do
      it 'should be defined' do
        assert_respond_to Klarna, :mode
      end

      it 'should have default setting: :test' do
        assert_equal :test, Klarna.mode
      end

      it 'should be configurable' do
        swap Klarna, :mode => :production do
          assert_equal :production, Klarna.mode
        end
      end
    end

    describe '.country' do
      it 'should be defined' do
        assert_respond_to Klarna, :country
      end

      it 'should have default setting: SE' do
        assert_equal :SE, Klarna.country
      end

      it 'should be configurable' do
        swap Klarna, :country => :NO do
          assert_equal :NO, Klarna.country
        end
      end
    end

    describe '.store_id' do
      it 'should be defined' do
        assert_respond_to Klarna, :store_id
      end

      it 'should have default setting: nil' do
        assert_equal nil, Klarna.store_id
      end

      it 'should be configurable' do
        swap Klarna, :store_id => '123' do
          assert_equal 123, Klarna.store_id
        end
      end
    end

    describe '.store_secret' do
      it 'should be defined' do
        assert_respond_to Klarna, :store_secret
      end

      it 'should have default setting: nil' do
        assert_equal nil, Klarna.store_secret
      end

      it 'should be configurable' do
        swap Klarna, :store_secret => 'ABC123' do
          assert_equal 'ABC123', Klarna.store_secret
        end
      end
    end

    describe '.store_pclasses' do
      it 'should be defined' do
        assert_respond_to Klarna, :store_pclasses
      end

      it 'should have default setting: SE' do
        assert_equal nil, Klarna.store_pclasses
      end

      # TODO:
      # it 'should be configurable' do
      # end
    end

    describe '.store_config_file' do
      it 'should be defined' do
        assert_respond_to Klarna, :mode
      end

      it 'should have default setting: nil' do
        Klarna.reset!
        assert_equal File.join(ENV['HOME'], '.klarna.yml'), Klarna.store_config_file
      end

      it 'should be configurable' do
        swap Klarna, :store_config_file => '/path/to/a/file' do
          assert_equal '/path/to/a/file', Klarna.store_config_file
        end
      end
    end

    describe '.logger' do
      it 'should be defined' do
        assert_respond_to Klarna, :logger
      end

      it 'should have default logger' do
        assert_instance_of Logger, Klarna.logger
      end

      it 'should be configurable' do
        custom_logger = ::Logger.new(::STDOUT)
        swap Klarna, :logger => custom_logger do
          assert_equal custom_logger, Klarna.logger
        end
      end
    end

    describe '.http_logging' do
      it 'should be defined' do
        assert_respond_to Klarna, :http_logging
      end

      it 'should have default setting: false' do
        assert_equal false, Klarna.http_logging
      end

      it 'should be configurable' do
        swap Klarna, :http_logging => true do
          assert_equal true, Klarna.http_logging
        end
      end
    end

  end

  describe "Helpers" do

    describe '.setup' do
      it 'should be defined' do
        assert_respond_to Klarna, :setup
      end

      it 'should be possible to change settings in a block' do
        Klarna.http_logging = false
        assert_equal false, Klarna.http_logging

        Klarna.setup do |c|
          c.http_logging = true
        end
        assert_equal true, Klarna.http_logging
      end
    end

    describe '.log' do
      it 'should be defined' do
        assert_respond_to Klarna, :log
      end
    end

    describe '.load_credentials_from_file' do
      it 'should be defined' do
        assert_respond_to Klarna, :load_credentials_from_file
      end

      it 'should load settings from a external YAML config file' do
        # TODO: Test loading settings from fixtures/klarna.yml
      end
    end

  end

end
