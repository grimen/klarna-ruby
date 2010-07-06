# encoding: utf-8

module Klarna
  module API
    module Methods
      module Special

        # Change the quantity of a specific item in a passive invoice.
        #
        def update_goods_quantity(invoice_id, article_id, new_quantity)
          params = [
            self.store_id,
            self.digest(article_id, new_quantity),
            invoice_id,
            article_id,
            new_quantity
          ]
          self.call_with_defaults(:update_goods_qty, *params)
        end

        # Change the amount of a fee (for example the invoice fee) in a passive invoice.
        #
        def update_charge_amount(invoice_id, charge_type, new_amount)
          params = [
            self.store_id,
            self.digest(invoice_id, charge_type, new_amount),
            invoice_id,
            charge_type,
            new_amount
          ]
          self.call_with_defaults(:update_charge_amount, *params)
        end

        # Change the store’s order number for a specific invoice.
        #
        def update_order_number(invoice_id, new_order_id)
          params = [
            self.store_id,
            invoice_id,
            self.digest(invoice_id, new_order_id),
            new_order_id
          ]
          self.call_with_defaults(:update_orderno, *params)
        end
        alias :update_order_id :update_order_number

        # Retrieve the address for an invoice.
        #
        def invoice_address(invoice_id)
          params = [
            self.store_id,
            invoice_id,
            self.digest(invoice_id)
          ]
          self.call_with_defaults(:invoice_address, *params)
        end
        alias :get_invoice_address :invoice_address

        # Retrieve the total amount of an invoice - optionally only partly.
        #
        def invoice_amount(invoice_id, specified_articles = nil)
          params = [
            self.store_id,
            invoice_id
          ]
          # Only partly?
          if specified_articles.present?
            params << specified_articles
            params << self.digest(invoice_id, specified_articles.collect { |a| a.join(':') }.join(':'))
            method = :invoice_part_amount
          else
            params << self.digest(invoice_id)
            method = :invoice_amount
          end
          self.call_with_defaults(method, *params)
        end
        alias :get_invoice_amount :invoice_amount

        # Check if invoice is paid.
        #
        def invoice_paid?(invoice_id)
          params = [
            invoice_id,
            self.store_id,
            self.digest(invoice_id)
          ]
          self.call_with_defaults(:is_invoice_paid, *params)
        end

        # Purpose: Oobtain pcalss values from Klarna.
        #
        # == Note:
        #
        #   This function is only to be used to obtain pclass values for stores ONE TIME ONLY.
        #   It is not allowed to use this function for continuous calculation of monthly costs or
        #   with every purchase in the checkout. The pclass values do NOT change.
        #
        def get_pclasses(currency_code)
          params = [
            self.store_id,
            currency_code,
            self.digest(currency_code)
          ]
          self.call_with_defaults(:get_pclasses, *params)
        end

      end
    end
  end
end
