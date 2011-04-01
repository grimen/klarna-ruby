# encoding: utf-8

module Klarna
  module API
    module Methods
      module Invoicing

        # == TODO:
        #
        #   * #total_credit_purchase_cost
        #

        # Create an invoice.
        #
        def add_invoice(store_user_id, order_id, goods_list, shipping_fee,
                            handling_fee, shipment_type, pno, first_name, last_name, address, client_ip,
                            currency, country, language, pno_encoding, pclass = nil, annual_salary = nil,
                            password = nil, ready_date = nil, comment = nil, rand_string = nil, new_password = nil, flags = nil)
          shipment_type = ::Klarna::API.id_for(:shipment_type, shipment_type)
          currency = ::Klarna::API.id_for(:currency, currency)
          country = ::Klarna::API.id_for(:country, country)
          language = ::Klarna::API.id_for(:language, language)
          pno_encoding = ::Klarna::API.id_for(:pno_format, pno_encoding)
          pclass = pclass ? ::Klarna::API.id_for(:pclass, pclass) : -1
          flags = ::Klarna::API.parse_flags(:INVOICE, flags)

          params = [
            self.store_id,
            store_user_id,
            self.digest(goods_list.collect { |g| g[:goods][:title] }, :store_id => false),
            order_id,
            goods_list,
            shipping_fee,
            shipment_type,
            handling_fee,
            pno,
            first_name,
            last_name,
            address,
            password.to_s,
            client_ip.to_s,
            new_password.to_s,
            flags.to_i,
            comment.to_s,
            ready_date.to_s,
            rand_string.to_s,
            currency,
            country,
            language,
            pno_encoding,
            pclass,
            annual_salary.to_i
          ]

          self.call(:add_invoice, *params)
        end
        alias :add_transaction :add_invoice

        # Activate a passive invoice - optionally only partly.
        #
        # == Note:
        #
        #   This function call cannot activate an invoice created in test mode. It is however possible
        #   to manually activate such an invoice.
        #
        #   When partially activating an invoice only the articles and quantities specified by
        #   you will be activated. A passive invoice is created containing the articles on the
        #   original invoice not activated.
        #
        def activate_invoice(invoice_no, articles = nil)
          # TODO: Parse/Validate invoice_no as :integer
          # TODO: Parse/Valdiate articles as array of articles

          params = [
            self.store_id,
            invoice_no
          ]

          # Only partly?
          if articles.present?
            params << articles
            params << self.digest(invoice_no, articles.collect { |a| a.join(':') }.join(':'))
            method = :activate_part
          else
            params << self.digest(invoice_no)
            method = :activate_invoice
          end

          self.call(method, *params)
        end
        alias :activate_part :activate_invoice

        # Delete a passive invoice.
        #
        def delete_invoice(invoice_no)
          # TODO: Parse/Validate invoice_no as :integer

          params = [
            self.store_id,
            invoice_no,
            self.digest(invoice_no)
          ]

          self.call(:delete_invoice, *params)
        end

        # Give discounts for invoices.
        #
        def return_amount(invoice_no, amount, vat)
          # params = [
          #   self.store_id,
          #   invoice_no,
          #   amount,
          #   vat,
          #   self.digest(invoice_no)
          # ]
          # self.call(:return_amount, *params)
          raise NotImplementedError
        end

        # Return a invoice - optionally only partly.
        #
        def credit_invoice(invoice_no, credit_id, articles = nil)
          # params = [
          #   self.store_id,
          #   invoice_no,
          #   credit_id,
          # ]
          # # Only partly?
          # if articles.present?
          #   params << articles
          #   params << self.digest(invoice_no, articles.collect { |a| a.join(':') }.join(':'))
          #   method = :credit_part
          # else
          #   params << self.digest(invoice_no)
          #   method = :credit_invoice
          # end
          # self.call(method, *params)
          raise NotImplementedError
        end

        # Send an active invoice to the customer via e-mail.
        #
        # == Note:
        #
        #   Regular postal service is used if the customer lacks an e-mail address.
        #
        def email_invoice(invoice_no)
          # TODO: Parse/Validate invoice_no as integer

          params = [
            self.store_id,
            invoice_no,
            self.digest(invoice_no)
          ]

          self.call(:email_invoice, *params)
        end

        # Request a postal send-out of an active invoice to a customer by Klarna.
        #
        def send_invoice(invoice_no)
          # TODO: Parse/Validate invoice_no as integer

          params = [
            self.store_id,
            invoice_no,
            self.digest(invoice_no)
          ]

          self.call(:send_invoice, *params)
        end

        # Create quantity and article number (i.e. the +articles+ argument for the
        # +activate_part+ and +credit_part+ function).
        #
        def make_article(quantity, article_no)
          quantity = quantity.to_i
          article_no = article_no.to_s
          [quantity, article_no]
        end

        # Change the quantity of a specific item in a passive invoice.
        #
        def update_goods_quantity(invoice_no, article_no, new_quantity)
          # TODO: Parse/Validate invoice_no as integer
          # TODO: Parse/Validate article_no as string
          # TODO: Parse/Validate new_quantity as integer

          params = [
            self.store_id,
            self.digest(invoice_no, article_no, new_quantity, :store_id => false),
            invoice_no,
            article_no,
            new_quantity
          ]

          self.call(:update_goods_qty, *params)
        end

        # Change the amount of a fee (for example the invoice fee) in a passive invoice.
        #
        def update_charge_amount(invoice_no, charge_type, new_amount)
          # TODO: Parse/Validate invoice_no as integer
          # TODO: Parse/Validate charge_type as integer/charge-type
          # TODO: Parse/Validate new_amount as integer (or parse from decimal)

          params = [
            self.store_id,
            self.digest(invoice_no, charge_type, new_amount),
            invoice_no,
            charge_type,
            new_amount
          ]

          self.call(:update_charge_amount, *params)
        end

        # Change the store’s order number for a specific invoice.
        #
        def update_order_no(invoice_no, new_order_no)
          # TODO: Parse/Validate invoice_no as integer
          # TODO: Parse/Validate new_order_no as integer

          params = [
            self.store_id,
            invoice_no,
            self.digest(invoice_no, new_order_no),
            new_order_no
          ]

          self.call(:update_orderno, *params)
        end

        # Retrieve the address for an invoice.
        #
        def invoice_address(invoice_no)
          # TODO: Parse/Validate invoice_no as integer

          params = [
            self.store_id,
            invoice_no,
            self.digest(invoice_no)
          ]

          self.call(:invoice_address, *params).tap do |result|
            result[5] = result[5].to_s.upcase
          end
        end
        alias :get_invoice_address :invoice_address

        # Retrieve the total amount of an invoice - optionally only partly.
        #
        def invoice_amount(invoice_no, articles = nil)
          # TODO: Parse/Validate invoice_no as integer

          params = [
            self.store_id,
            invoice_no
          ]

          # Only partly?
          if articles.present?
            params << articles
            params << self.digest(invoice_no, articles.collect { |a| a.join(':') }.join(':'))
            method = :invoice_part_amount
          else
            params << self.digest(invoice_no)
            method = :invoice_amount
          end

          self.call(method, *params)
        end
        alias :get_invoice_amount :invoice_amount

        # Check if invoice is paid.
        #
        def invoice_paid?(invoice_no)
          # TODO: Parse/Validate invoice_no as numeric value (string)

          params = [
            invoice_no,
            self.store_id,
            self.digest(invoice_no)
          ]

          result = self.call(:is_invoice_paid, *params)
          result == 'unpaid' ? false : true
        end

      end
    end
  end
end
