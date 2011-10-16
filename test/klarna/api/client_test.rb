# encoding: utf-8
require 'test_helper'

describe Klarna::API::Client do

  before do
    Klarna.reset!
    @client = Klarna::API::Client.new(VALID_STORE_ID, VALID_STORE_SECRET)
  end

  describe 'Initialization' do
    it 'should require store-ID and store-secret' do
      assert_raises(Klarna::API::Errors::KlarnaCredentialsError) do
        @client = Klarna::API::Client.new
      end

      assert_raises(Klarna::API::Errors::KlarnaCredentialsError) do
        @client = Klarna::API::Client.new(VALID_STORE_ID)
      end

      assert @client = Klarna::API::Client.new(VALID_STORE_ID, VALID_STORE_SECRET)
    end
  end

  describe "Configuration" do
    describe "Configurable" do

      describe '#store_id' do
        it 'should be defined' do
          assert_respond_to @client, :store_id
        end
      end

      describe '#store_secret' do
        it 'should be defined' do
          assert_respond_to @client, :store_secret
        end
      end

      describe '#mode' do
        it 'should be defined' do
          assert_respond_to @client, :mode
        end

        it 'should have default value: :test' do
          assert_equal :test, Klarna::API::Client.new(VALID_STORE_ID, VALID_STORE_SECRET).mode
        end

        it 'should use default value unless specified' do
          swap Klarna, :mode => :test do
            client = Klarna::API::Client.new(VALID_STORE_ID, VALID_STORE_SECRET)
            assert_equal :test, client.mode
          end

          swap Klarna, :mode => :production do
            client = Klarna::API::Client.new(VALID_STORE_ID, VALID_STORE_SECRET)
            assert_equal :production, client.mode
          end
        end

        it 'could override default value' do
          swap Klarna, :mode => :test do
            client = Klarna::API::Client.new(VALID_STORE_ID, VALID_STORE_SECRET, :mode => :production)
            assert_equal :production, client.mode
          end

          swap Klarna, :mode => :production do
            client = Klarna::API::Client.new(VALID_STORE_ID, VALID_STORE_SECRET, :mode => :test)
            assert_equal :test, client.mode
          end
        end
      end

      describe '#timeout' do
        it 'should be defined' do
          assert_respond_to @client, :timeout
        end

        it 'should have default value: 10 seconds' do
          assert_equal 10, @client.timeout
        end
      end
    end

    describe "Mode-specific Attributes" do
      describe '#ssl?' do
        it 'should be defined' do
          assert_respond_to @client, :ssl?
        end

        it 'should be true only if protocol is HTTPS' do
          # TODO
        end
      end

      describe "Autodetected attributes" do
        describe '#protocol' do
          it 'should be defined' do
            assert_respond_to @client, :protocol
          end

          describe 'mode: test' do
            before do
              @client.mode = :test
            end

            it 'should be: http' do
              assert_equal 'http', @client.protocol
            end
          end

          describe 'mode: test' do
            before do
              @client.mode = :production
            end

            it 'should be: https' do
              assert_equal 'https', @client.protocol
            end
          end
        end

        describe '#host' do
          it 'should be defined' do
            assert_respond_to @client, :host
          end

          describe 'mode: test' do
            before do
              @client.mode = :test
            end

            it 'should be: beta-test.klarna.com' do
              assert_equal @client.host, 'payment-beta.klarna.com'
            end
          end

          describe 'mode: production' do
            before do
              @client.mode = :production
            end

            it 'should be: payment.klarna.com' do
              assert_equal @client.host, 'payment.klarna.com'
            end
          end
        end

        describe '#port' do
          it 'should be defined' do
            assert_respond_to @client, :port
          end

          describe 'mode: test' do
            before do
              @client.mode = :test
            end

            it 'should be: 80' do
              assert_equal 80, @client.port
            end
          end

          describe 'mode: production' do
            before do
              @client.mode = :production
            end

            it 'should be: 443' do
              assert_equal 443, @client.port
            end
          end
        end

        describe '#endpoint_uri' do
          describe 'mode: test' do
            before do
              @client.mode = :test
            end

            it 'should be: http://beta-test.klarna.com:80' do
              assert_equal 'http://payment-beta.klarna.com:80', @client.endpoint_uri
            end
          end

          describe 'mode: production' do
            before do
              @client.mode = :production
            end

            it 'should be: https://payment.klarna.com:443' do
              assert_equal 'https://payment.klarna.com:443', @client.endpoint_uri
            end
          end

        end
      end
    end
  end

  describe "Helpers" do

    describe '#call' do
      it 'should be defined' do
        assert_respond_to @client, :call
      end

      it 'should raise Klarna service error for dummie method: -99' do
        assert_raises Klarna::API::Errors::KlarnaServiceError do
          begin
            @client.call(:hello)
          rescue Klarna::API::Errors::KlarnaServiceError => e
            assert_equal -99, e.error_code
            raise e
          end
        end
      end
    end

    describe '#digest' do
      it 'should be defined' do
        assert_respond_to @client, :digest
      end

      it 'should calculate a valid digest secret for one value' do
        # TODO
      end

      it 'should calculate a valid digest secret for an array of values' do
        # TODO
      end

      it 'should raise error if specified value is nor a string or an array' do
        # TODO
      end
    end

    describe '#content_type_headers' do
      it 'should be defined' do
        assert_respond_to @client, :content_type_headers
      end

      it 'should have header: Accept-Charset: iso-8859-1' do
        assert_equal 'iso-8859-1', @client.send(:content_type_headers)['Accept-Charset']
      end

      it 'should have header: Content-Type: text/xml;charset=iso-8859-1' do
        assert_equal 'text/xml;charset=iso-8859-1', @client.send(:'content_type_headers')['Content-Type']
      end

      it 'should have header: Connection: close' do
        assert_equal 'close', @client.send(:content_type_headers)['Connection']
      end

      it 'should have header: Accept-Charset: iso-8859-1' do
        assert_equal 'ruby/xmlrpc', @client.send(:content_type_headers)['User-Agent']
      end
    end

    describe '#add_meta_params' do
      it 'should be defined' do
        assert_respond_to @client, :add_meta_params
      end

      it %Q{should push default RPC-params/arguments: protocol version + client version ("1.0", "#{::XMLRPC::Client::USER_AGENT}")} do
        assert_equal ["#{::Klarna::API::PROTOCOL_VERSION}", "#{::XMLRPC::Client::USER_AGENT}"], @client.send(:add_meta_params)
      end
    end

  end

end
