# encoding: utf-8
 require 'test_helper'

describe Klarna::API::Methods::Invoicing do

  # TODO: Mock responses using VCR.

  INVALID_ORDER_NO = '12312312312312312'

  before do
    valid_credentials!
    @klarna = Klarna::API::Client.new
    @klarna.client_ip = '85.230.98.196'

    @protocol_version = ::Klarna::API::PROTOCOL_VERSION.to_s
    @user_agent = ::XMLRPC::Client::USER_AGENT.to_s

    expose_protected_methods_in @klarna.class

    @order_items = []
    @order_items << @klarna.make_goods(1, 'ABC1', "T-shirt 1", 1.00 * 100, 25, 0, :INC_VAT => true)
    @order_items << @klarna.make_goods(3, 'ABC2', "T-shirt 2", 7.00 * 100, 25, 0, :INC_VAT => true)
    @order_items << @klarna.make_goods(7, 'ABC3', "T-shirt 3", 17.00 * 100, 25, 0, :INC_VAT => true)
    @order_items_total = (1 * (1.00 * 100) + 3 * (7.00 * 100) + 7 * (17.00 * 100)).to_i

    @address_SE = @klarna.make_address("c/o Lidin", "Junibackg. 42", "23634", "Höllviken", :SE, "076 526 00 00", "076 526 00 00", "karl.lidin@klarna.com")

    @valid_invoice_args_SE =
      ['USER-4304158399', 'ORDER-1', @order_items, 0, 0, :NORMAL, '4304158399', 'Karl', 'Lidin', @address_SE, '85.230.98.196', :SEK, :SE, :SV, :SE, nil, nil, nil, nil, nil, nil, nil, 2]
  end

  # Spec: http://integration.klarna.com/en/api/standard-integration/functions/addtransaction
  describe '#add_invoice' do
    it 'should be defined' do
      assert_respond_to @klarna, :add_transaction
    end

    describe "SE" do
      it 'should create order successfully with valid arguments' do
        invoice_no = @klarna.add_transaction(
          'USER-4304158399', 'ORDER-1', @order_items, 0, 0, ::Klarna::API::SHIPMENT_TYPES[:NORMAL], '4304158399', 'Karl', 'Lidin', @address_SE, '85.230.98.196', ::Klarna::API::CURRENCIES[:SEK], ::Klarna::API::COUNTRIES[:SE], ::Klarna::API::LANGUAGES[:SV], ::Klarna::API::PNO_FORMATS[:SE])

        assert_match /^\d+$/, invoice_no
      end

      it 'should accept shortcut arguments for: shipment_type, currency, country, language, pno_encoding' do
        invoice_no = @klarna.add_invoice(
          'USER-4304158399', 'ORDER-1', @order_items, 0, 0, :NORMAL, '4304158399', 'Karl', 'Lidin', @address_SE, '85.230.98.196', :SEK, :SE, :SV, :SE)

        assert_match /^\d+$/, invoice_no
      end
    end
  end

  # NOTE: active_invoice don't seem to work with the Klarna 2.0 backend currently, raises "invoice_in_test_mode" (which it didn't before).

  # Spec:
  #   http://integration.klarna.com/en/api/standard-integration/functions/activateinvoice
  #   http://integration.klarna.com/en/api/standard-integration/functions/activatepart (combined)
  describe '#activate_invoice' do
    it 'should be defined' do
      assert_respond_to @klarna, :activate_invoice
    end

    describe 'full' do
      it 'should raise error for when trying to activate an non-existing invoice' do
        assert_raises ::Klarna::API::Errors::KlarnaServiceError do
          @klarna.activate_invoice(INVALID_ORDER_NO)
        end
      end

      it 'should successfully activate an existing invoice' # do
    #     invoice_no = @klarna.add_invoice(*@valid_invoice_args_SE)
    #
    #     assert_equal "#{@klarna.endpoint_uri}/temp/#{invoice_no}.pdf", @klarna.activate_invoice(invoice_no)
    #   end
    end

    describe 'partial' do
      it 'should raise error for when trying to activate an non-existing invoice' do
        assert_raises ::Klarna::API::Errors::KlarnaServiceError do
          activate_articles = [@order_items.first]
          @klarna.activate_invoice(INVALID_ORDER_NO, activate_articles)
        end
      end

      # FAILS: Klarna API 2.0 don't support this for test-accounts. :(
      it 'should successfully activate an existing partial invoice' # do
      #     invoice_no = @klarna.add_invoice(*@valid_invoice_args_SE)
      #     activate_articles = [@order_items.first]
      #
      #     assert_equal "#{@klarna.endpoint_uri}/temp/#{invoice_no}.pdf", @klarna.activate_invoice(invoice_no, activate_articles)
      #   end
    end
  end

  # Spec:
  #   http://integration.klarna.com/en/api/standard-integration/functions/deleteinvoice
  describe '#delete_invoice' do
    it 'should be defined' do
      assert_respond_to @klarna, :delete_invoice
    end

    it 'should raise error when trying to delete an non-existing invoice' do
      assert_raises ::Klarna::API::Errors::KlarnaServiceError do
        @klarna.delete_invoice(INVALID_ORDER_NO)
      end
    end

    it 'should successfully delete an existing invoice' do
      invoice_no = @klarna.add_invoice(*@valid_invoice_args_SE)

      assert_equal 'ok', @klarna.delete_invoice(invoice_no)
    end
  end

  # Spec:
  #   http://integration.klarna.com/en/api/invoice-handling-functions/functions/returnamount
  describe '#return_amount' do
    it 'should be defined' do
      assert_respond_to @klarna, :return_amount
    end

    it 'should raise error for non-existing invoice' do
        assert_raises ::Klarna::API::Errors::KlarnaServiceError do
          amount = 100
          vat = 25
          @klarna.return_amount(INVALID_ORDER_NO, amount, vat)
        end
      end

      it 'should raise error for existing but un-activated invoice' do
        assert_raises ::Klarna::API::Errors::KlarnaServiceError do
          invoice_no = @klarna.add_invoice(*@valid_invoice_args_SE)
          amount = 100
          vat = 25

          assert_equal invoice_no, @klarna.return_amount(invoice_no, amount, vat)
        end
      end

      # FAILS: Klarna API 2.0 don't support this for test-accounts. :(
      it 'should successfully return amount for an activated invoice' # do
      #   invoice_no = @klarna.add_invoice(*@valid_invoice_args_SE)
      #   amount = 100
      #   vat = 25
      #
      #   assert_equal invoice_no, @klarna.credit_invoice(invoice_no, credit_no)
      # end
  end

  # Spec:
  #   http://integration.klarna.com/en/api/invoice-handling-functions/functions/returnamount
  describe '#credit_invoice' do
    it 'should be defined' do
      assert_respond_to @klarna, :credit_invoice
    end

    describe 'full' do
      it 'should raise error for non-existing invoice' do
        assert_raises ::Klarna::API::Errors::KlarnaServiceError do
          credit_no = ''
          @klarna.credit_invoice(INVALID_ORDER_NO, credit_no)
        end
      end

      it 'should raise error for existing but un-activated invoice' do
        assert_raises ::Klarna::API::Errors::KlarnaServiceError do
          invoice_no = @klarna.add_invoice(*@valid_invoice_args_SE)
          credit_no = ''
          @klarna.credit_invoice(invoice_no, credit_no)
        end
      end

      # FAILS: Klarna API 2.0 don't support this for test-accounts. :(
      it 'should successfully credit an activated invoice' # do
      #   invoice_no = @klarna.add_invoice(*@valid_invoice_args_SE)
      #   invoice_url = @klarna.activate_invoice(invoice_no)
      #   credit_no = ''
      #
      #   assert_equal invoice_no, @klarna.credit_invoice(invoice_no, credit_no)
      # end
    end

    describe 'partial' do
      it 'should raise error for existing but un-activated invoice' do
        assert_raises ::Klarna::API::Errors::KlarnaServiceError do
          invoice_no = @klarna.add_invoice(*@valid_invoice_args_SE)
          refund_articles = [@order_items.first]
          credit_no = ''
          @klarna.credit_invoice(invoice_no, credit_no, refund_articles)
        end
      end

      it 'should successfully credit an activated invoice' # do
      #   invoice_no = @klarna.add_invoice(*@valid_invoice_args_SE)
      #   invoice_url = @klarna.activate_invoice(invoice_no)
      #   refund_articles = [@order_items.first]
      #   credit_no = ''
      #
      #   assert_equal invoice_no, @klarna.credit_invoice(invoice_no, credit_no, refund_articles)
      # end
    end
  end

  # Spec:
  #   http://integration.klarna.com/en/api/invoice-handling-functions/functions/emailinvoice
  describe '#email_invoice' do
    it 'should be defined' do
      assert_respond_to @klarna, :email_invoice
    end

    it 'should raise error for e-mail request of an existing but un-activated invoice' do
      assert_raises ::Klarna::API::Errors::KlarnaServiceError do
        invoice_no = @klarna.add_invoice(*@valid_invoice_args_SE)
        @klarna.email_invoice(invoice_no)
      end
    end

    # FAILS: Klarna API 2.0 don't support this for test-accounts. :(
    it 'should successfully accept email request of an activated invoice' # do
    #   invoice_no = @klarna.add_invoice(*@valid_invoice_args_SE)
    #   invoice_url = @klarna.activate_invoice(invoice_no)
    #
    #   assert_equal invoice_no, @klarna.email_invoice(invoice_no)
    # end
  end

  # Spec:
  #   http://integration.klarna.com/en/api/invoice-handling-functions/functions/sendinvoice
  describe '#send_invoice' do
    it 'should be defined' do
      assert_respond_to @klarna, :send_invoice
    end

    it 'should raise error for snail-mail request of an existing but un-activated invoice' do
      assert_raises ::Klarna::API::Errors::KlarnaServiceError do
        invoice_no = @klarna.add_invoice(*@valid_invoice_args_SE)
        @klarna.send_invoice(invoice_no)
      end
    end

    # FAILS: Klarna API 2.0 don't support this for test-accounts. :(
    it 'should successfully accept snail-mail request of an activated invoice' # do
    #   invoice_no = @klarna.add_invoice(*@valid_invoice_args_SE)
    #   invoice_url = @klarna.activate_invoice(invoice_no)
    #
    #   assert_equal invoice_no, @klarna.send_invoice(invoice_no)
    # end
  end

  # Spec:
  #   http://integration.klarna.com/en/api/invoice-handling-functions/functions/mkartno
  describe '#make_article' do
    it 'should be defined' do
      assert_respond_to @klarna, :make_article
    end

    it 'should generate valid article structure' do
      assert_equal [5, '12345'], @klarna.make_article(5, 12345)
      assert_equal [5, '12345'], @klarna.make_article(5, '12345')
    end
  end

  # Spec:
  #   http://integration.klarna.com/en/api/other-functions/functions/updategoodsqty
  describe '#update_goods_quantity' do
    it 'should be defined' do
      assert_respond_to @klarna, :update_goods_quantity
    end

    it 'should raise error for an non-existing invoice' do
      assert_raises ::Klarna::API::Errors::KlarnaServiceError do
        @klarna.update_goods_quantity(INVALID_ORDER_NO, 'ABC1', 10)
      end
    end

    it 'should raise error for an non-existing article-no for an existing invoice' do
      assert_raises ::Klarna::API::Errors::KlarnaServiceError do
        invoice_no = @klarna.add_invoice(*@valid_invoice_args_SE)

        @klarna.update_goods_quantity(invoice_no, 'XXX', 10)
      end
    end

    it 'should successfully update goods quantity for an existing invoice and valid article-no' do
      invoice_no = @klarna.add_invoice(*@valid_invoice_args_SE)

      assert_equal invoice_no, @klarna.update_goods_quantity(invoice_no, 'ABC1', 10)
    end
  end

  # Spec:
  #   http://integration.klarna.com/en/api/other-functions/functions/updatechargeamount
  describe '#update_charge_amount' do
    it 'should be defined' do
      assert_respond_to @klarna, :update_charge_amount
    end

    it 'should raise error for an non-existing invoice' do
      assert_raises ::Klarna::API::Errors::KlarnaServiceError do
        @klarna.update_charge_amount(INVALID_ORDER_NO, 1, 10.00 * 100)
      end
    end

    it 'should successfully update shipment fee for an existing invoice'

    it 'should successfully update handling fee for an existing invoice'
  end

  # Spec: http://integration.klarna.com/en/api/other-functions/functions/updateorderno
  describe '#update_order_no' do
    it 'should be defined' do
      assert_respond_to @klarna, :update_order_no
    end

    it 'should raise error for an non-existing invoice' do
      assert_raises ::Klarna::API::Errors::KlarnaServiceError do
        @klarna.update_order_no(INVALID_ORDER_NO, '123')
      end
    end

    # FIXME: Throws "invno"-error - don't know why. :S
    it 'should successfully update order-no for an existing invoice' # do
    #   invoice_no = @klarna.add_invoice(*@valid_invoice_args_SE)
    #   new_invoice_no = (invoice_no.to_i + 1).to_s

    #   assert_equal new_invoice_no, @klarna.update_order_no(invoice_no, new_invoice_no)
    # end
  end

  # Spec:
  #   http://integration.klarna.com/en/api/other-functions/functions/invoiceaddress
  describe '#invoice_address' do
    it 'should be defined' do
      assert_respond_to @klarna, :invoice_address
    end

    it 'should raise error for an non-existing invoice' do
      assert_raises ::Klarna::API::Errors::KlarnaServiceError do
        @klarna.invoice_address(INVALID_ORDER_NO)
      end
    end

    it 'should successfully return the address for an existing invoice' do
      invoice_no = @klarna.add_invoice(*@valid_invoice_args_SE)

      assert_equal ["Karl", "Lidin", "Junibacksg 42", "23634", "Hollviken", 'SE'], @klarna.invoice_address(invoice_no)
    end
  end

  # Spec:
  #   http://integration.klarna.com/en/api/other-functions/functions/invoiceamount
  #   http://integration.klarna.com/en/api/other-functions/functions/invoicepartamount (combined)
  describe '#invoice_amount' do
    it 'should be defined' do
      assert_respond_to @klarna, :invoice_amount
    end

    describe 'full' do
      it 'should raise error for an non-existing invoice' do
        assert_raises ::Klarna::API::Errors::KlarnaServiceError do
          @klarna.invoice_amount(INVALID_ORDER_NO)
        end
      end

      it 'should successfully return the invoice amount for an existing invoice' do
        invoice_no = @klarna.add_invoice(*@valid_invoice_args_SE)

        assert_equal @order_items_total, @klarna.invoice_amount(invoice_no)
      end
    end

    describe 'partial' do
      it 'should raise error for an non-existing invoice' do
        assert_raises ::Klarna::API::Errors::KlarnaServiceError do
          articles = [@order_items.last]
          @klarna.invoice_amount(INVALID_ORDER_NO, articles)
        end
      end

      it 'should successfully return the invoice amount for an existing invoice' do
        invoice_no = @klarna.add_invoice(*@valid_invoice_args_SE)
        articles = [@order_items.last]

        assert_equal 7*(17.00 * 100), @klarna.invoice_amount(invoice_no, articles)
      end
    end
  end

  describe '#invoice_paid?' do
    it 'should be defined' do
      assert_respond_to @klarna, :invoice_paid?
    end

    it 'should raise error for an non-existing invoice' do
      assert_raises ::Klarna::API::Errors::KlarnaServiceError do
        @klarna.invoice_paid?(INVALID_ORDER_NO)
      end
    end

    it 'should be unpaid for an existing but un-activated invoice' do
      invoice_no = @klarna.add_invoice(*@valid_invoice_args_SE)

      assert_equal false, @klarna.invoice_paid?(invoice_no)
    end
  end

end