require File.join(File.dirname(__FILE__), *%w[test_helper])

class KlarnaTest < ActiveSupport::TestCase

  test 'should be configurable using setup helper' do
    swap Klarna, :credentials_file => '/path/to/a/file' do
      assert_equal '/path/to/a/file', Klarna.credentials_file
    end

    swap Klarna, :mode => :production do
      assert_equal :production, Klarna.mode
    end

    swap Klarna, :country => :NO do
      assert_equal :NO, Klarna.country
    end

    swap Klarna, :store_id => '123' do
      assert_equal '123', Klarna.store_id
    end

    swap Klarna, :store_secret => 'ABC123' do
      assert_equal 'ABC123', Klarna.store_secret
    end
  end

end