# encoding: utf-8
 require 'test_helper'

describe Klarna::API::Methods::Invoicing do

  # TODO: Mock responses.

  INVALID_ORDER_NO = '12312312312312312'

  before do
    valid_credentials!
    @client = Klarna::API::Client.new

    @protocol_version = ::Klarna::API::PROTOCOL_VERSION.to_s
    @user_agent = ::XMLRPC::Client::USER_AGENT.to_s

    expose_protected_methods_in @client.class

    @order_items = []
    @order_items << @client.make_goods(1, 'ABC1', "T-shirt 1", 1.00 * 100, 25)
    @order_items << @client.make_goods(3, 'ABC2', "T-shirt 2", 7.00 * 100, 25)
    @order_items << @client.make_goods(7, 'ABC3', "T-shirt 3", 17.00 * 100, 25)
    @order_items_total = ((1 * (1.00 * 100) + 3 * (7.00 * 100) + 7 * (17.00 * 100)) * 1.25).to_i

    @address_SE = @client.make_address("c/o Lidin", "Junibackg. 42", "23634", "Höllviken", :SE, "076 526 00 00", "076 526 00 00", "karl.lidin@klarna.com")

    @valid_invoice_args_SE =
      ['USER-4304158399', 'ORDER-1', @order_items, 0, 0, :NORMAL, '4304158399', 'Karl', 'Lidin', @address_SE, '85.230.98.196', :SEK, :SE, :SV, :SE]
  end

  # Spec: http://integration.klarna.com/en/api/standard-integration/functions/addtransaction
  describe '#add_invoice' do
    it 'should be defined' do
      assert_respond_to @client, :add_transaction
    end

    describe "SE" do
      it 'should create order successfully with valid arguments' do
        invoice_no = @client.add_transaction(
          'USER-4304158399', 'ORDER-1', @order_items, 0, 0, ::Klarna::API::SHIPMENT_TYPES[:NORMAL], '4304158399', 'Karl', 'Lidin', @address_SE, '85.230.98.196', ::Klarna::API::CURRENCIES[:SEK], ::Klarna::API::COUNTRIES[:SE], ::Klarna::API::LANGUAGES[:SV], ::Klarna::API::PNO_FORMATS[:SE])

        assert_match /^\d+$/, invoice_no
      end

      it 'should accept shortcut arguments for: shipment_type, currency, country, language, pno_encoding' do
        invoice_no = @client.add_invoice(
          'USER-4304158399', 'ORDER-1', @order_items, 0, 0, :NORMAL, '4304158399', 'Karl', 'Lidin', @address_SE, '85.230.98.196', :SEK, :SE, :SV, :SE)

        assert_match /^\d+$/, invoice_no
      end
    end
  end

  # Spec:
  #   http://integration.klarna.com/en/api/standard-integration/functions/activateinvoice
  #   http://integration.klarna.com/en/api/standard-integration/functions/activatepart (combined)
  describe '#activate_invoice' do
    it 'should be defined' do
      assert_respond_to @client, :activate_invoice
    end

    it 'should raise error for when trying to activate an invalid/non-existing invoice' do
      assert_raises ::Klarna::API::Errors::KlarnaServiceError do
        @client.activate_invoice("12312312312312312")
      end
    end

    it 'should successfully activate an existing invoice' do
      invoice_no = @client.add_invoice(*@valid_invoice_args_SE)

      assert_equal "https://beta-test.klarna.com:4430/temp/#{invoice_no}.pdf", @client.activate_invoice(invoice_no)
    end

    # it 'should active an existing invoice partially if articles are specified as well'
  end

  # Spec: http://integration.klarna.com/en/api/standard-integration/functions/deleteinvoice
  describe '#delete_invoice' do
    it 'should be defined' do
      assert_respond_to @client, :delete_invoice
    end

    it 'should raise error when trying to delete an invalid/non-existing invoice' do
      assert_raises ::Klarna::API::Errors::KlarnaServiceError do
        @client.delete_invoice("12312312312312312")
      end
    end

    it 'should successfully delete an existing invoice' do
      invoice_no = @client.add_invoice(*@valid_invoice_args_SE)

      assert_equal 'ok', @client.delete_invoice(invoice_no)
    end
  end

  # Spec: http://integration.klarna.com/en/api/invoice-handling-functions/functions/returnamount
  describe '#return_amount' do
    it 'should be defined' do
      assert_respond_to @client, :return_amount
    end
  end

  # Spec: http://integration.klarna.com/en/api/invoice-handling-functions/functions/returnamount
  describe '#credit_invoice' do
    it 'should be defined' do
      assert_respond_to @client, :credit_invoice
    end
  end

  # Spec: http://integration.klarna.com/en/api/invoice-handling-functions/functions/emailinvoice
  describe '#email_invoice' do
    it 'should be defined' do
      assert_respond_to @client, :email_invoice
    end

    it 'should raise error for e-mail request of an existing but un-activated invoice' do
      assert_raises ::Klarna::API::Errors::KlarnaServiceError do
        invoice_no = @client.add_invoice(*@valid_invoice_args_SE)
        @client.email_invoice(invoice_no)
      end
    end

    it 'should successfully accept email request of an existing invoice' do
      invoice_no = @client.add_invoice(*@valid_invoice_args_SE)
      invoice_url = @client.activate_invoice(invoice_no)

      assert_equal invoice_no, @client.email_invoice(invoice_no)
    end
  end

  # Spec: http://integration.klarna.com/en/api/invoice-handling-functions/functions/sendinvoice
  describe '#send_invoice' do
    it 'should be defined' do
      assert_respond_to @client, :send_invoice
    end

    it 'should raise error for snail-mail request of an existing but un-activated invoice' do
      assert_raises ::Klarna::API::Errors::KlarnaServiceError do
        invoice_no = @client.add_invoice(*@valid_invoice_args_SE)
        @client.send_invoice(invoice_no)
      end
    end

    it 'should successfully accept snail-mail request of an existing and activated invoice' do
      invoice_no = @client.add_invoice(*@valid_invoice_args_SE)
      invoice_url = @client.activate_invoice(invoice_no)

      assert_equal invoice_no, @client.send_invoice(invoice_no)
    end
  end

  # Spec: http://integration.klarna.com/en/api/invoice-handling-functions/functions/mkartno
  describe '#make_article' do
    it 'should be defined' do
      assert_respond_to @client, :make_article
    end

    it 'should generate valid article structure' do
      assert_equal [5, '12345'], @client.make_article(5, 12345)
      assert_equal [5, '12345'], @client.make_article(5, '12345')
    end
  end

  # Spec: http://integration.klarna.com/en/api/other-functions/functions/updategoodsqty
  describe '#update_goods_quantity' do
    it 'should be defined' do
      assert_respond_to @client, :update_goods_quantity
    end

    it 'should raise error for an invalid/non-existing invoice' do
      assert_raises ::Klarna::API::Errors::KlarnaServiceError do
        @client.update_goods_quantity(INVALID_ORDER_NO, 'ABC1', 10)
      end
    end

    it 'should raise error for an invalid/non-existing article-no for a valid/existing invoice' do
      assert_raises ::Klarna::API::Errors::KlarnaServiceError do
        invoice_no = @client.add_invoice(*@valid_invoice_args_SE)

        @client.update_goods_quantity(invoice_no, 'XXX', 10)
      end
    end

    it 'should successfully update goods quantity for a valid/existing invoice and valid article-no' do
      invoice_no = @client.add_invoice(*@valid_invoice_args_SE)

      assert_equal invoice_no, @client.update_goods_quantity(invoice_no, 'ABC1', 10)
    end
  end

  # Spec: http://integration.klarna.com/en/api/other-functions/functions/updatechargeamount
  describe '#update_charge_amount' do
    it 'should be defined' do
      assert_respond_to @client, :update_charge_amount
    end

    it 'should raise error for an invalid/non-existing invoice' do
      assert_raises ::Klarna::API::Errors::KlarnaServiceError do
        @client.update_charge_amount(INVALID_ORDER_NO, 1, 10.00 * 100)
      end
    end

    # it 'should successfully update shipment fee for a valid/existing invoice'

    # it 'should successfully update handling fee for a valid/existing invoice'
  end

  # Spec: http://integration.klarna.com/en/api/other-functions/functions/updateorderno
  describe '#update_order_no' do
    it 'should be defined' do
      assert_respond_to @client, :update_order_no
    end

    it 'should raise error for an invalid/non-existing invoice' do
      assert_raises ::Klarna::API::Errors::KlarnaServiceError do
        @client.update_order_no(INVALID_ORDER_NO, '123')
      end
    end

    # Raises error, but don't know why...
    # it 'should successfully update order-no for a valid/existing invoice' do
    #   invoice_no = @client.add_invoice(*@valid_invoice_args_SE)
    #
    #   assert_equal "?", @client.update_order_no(invoice_no, (invoice_no.to_i + 1).to_s)
    # end
  end

  # Spec: http://integration.klarna.com/en/api/other-functions/functions/invoiceaddress
  describe '#invoice_address' do
    it 'should be defined' do
      assert_respond_to @client, :invoice_address
    end

    it 'should raise error for an invalid/non-existing invoice' do
      assert_raises ::Klarna::API::Errors::KlarnaServiceError do
        @client.invoice_address(INVALID_ORDER_NO)
      end
    end

    it 'should successfully return the address for a valid/existing invoice' do
      invoice_no = @client.add_invoice(*@valid_invoice_args_SE)

      assert_equal ["Karl", "Lidin", "Junibacksg 42", "23634", "Hollviken", 'SE'], @client.invoice_address(invoice_no)
    end
  end

  # Spec:
  #   http://integration.klarna.com/en/api/other-functions/functions/invoiceamount
  #   http://integration.klarna.com/en/api/other-functions/functions/invoicepartamount (combined)
  describe '#invoice_amount' do
    it 'should be defined' do
      assert_respond_to @client, :invoice_amount
    end

    it 'should raise error for an invalid/non-existing invoice' do
      assert_raises ::Klarna::API::Errors::KlarnaServiceError do
        @client.invoice_amount(INVALID_ORDER_NO)
      end
    end

    it 'should successfully return the invoice amount for a valid/existing invoice' do
      invoice_no = @client.add_invoice(*@valid_invoice_args_SE)

      assert_equal @order_items_total, @client.invoice_amount(invoice_no)
    end

    # it 'should successfully return the invoice amount for parts of an existing invoice if articles are specified as well'
  end

  describe '#invoice_paid?' do
    it 'should be defined' do
      assert_respond_to @client, :invoice_paid?
    end

    it 'should raise error for an invalid/non-existing invoice' do
      assert_raises ::Klarna::API::Errors::KlarnaServiceError do
        @client.invoice_paid?(INVALID_ORDER_NO)
      end
    end

    it 'should be unpaid for an existing but un-activated invoice' do
      invoice_no = @client.add_invoice(*@valid_invoice_args_SE)

      assert_equal false, @client.invoice_paid?(invoice_no)
    end
  end

end