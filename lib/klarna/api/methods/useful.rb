# encoding: utf-8

module Klarna
  module API
    module Methods
      module Useful

        # == TODO:
        #
        #   *total_credit_purchase_cost (Norway only, for some reason...)
        #

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
        def activate_invoice(invoice_id, specified_articles = nil)
          params = [
            self.store_id,
            invoice_id,
            self.digest(invoice_id)
          ]
          # Only partly?
          if specified_articles.present?
            params << specified_articles
            params << self.digest(invoice_id, specified_articles.collect { |a| a.join(':') }.join(':'))
            method = :activate_part
          else
            params << self.digest(invoice_id)
            method = :activate_invoice
          end
          self.call_with_defaults(method, *params)
        end

        # Delete a passive invoice.
        #
        def delete_invoice(invoice_id)
          params = [
            self.store_id,
            invoice_id,
            self.digest(invoice_id)
          ]
          self.call_with_defaults(:delete_invoice, *params)
        end

        # Give discounts for invoices.
        #
        def return_amount(invoice_id, amount, vat)
          params = [
            self.store_id,
            invoice_id,
            amount,
            vat,
            self.digest(invoice_id)
          ]
          self.call_with_defaults(:return_amount, *params)
        end

        # Return a invoice - optionally only partly.
        #
        def credit_invoice(invoice_id, credit_id, specified_articles = nil)
          params = [
            self.store_id,
            invoice_id,
            credit_id,
          ]
          # Only partly?
          if specified_articles.present?
            params << specified_articles
            params << self.digest(invoice_id, specified_articles.collect { |a| a.join(':') }.join(':'))
            method = :credit_part
          else
            params << self.digest(invoice_id)
            method = :credit_invoice
          end
          self.call_with_defaults(method, *params)
        end

        # Send an active invoice to the customer via e-mail.
        #
        # == Note:
        #
        #   Regular postal service is used if the customer lacks an e-mail address.
        #
        def email_invoice(invoice_id)
          params = [
            self.store_id,
            invoice_id,
            self.secret(invoice_id)
          ]
          self.call_with_defaults(:email_invoice, *params)
        end

        # Request a postal send-out of an active invoice to a customer by Klarna.
        #
        def send_invoice(invoice_id)
          params = [
            self.store_id,
            invoice_id,
            self.digest(invoice_id)
          ]
          self.call_with_defaults(:send_invoice, *params)
        end

        # Check if a user has an account.
        #
        def has_account?(pno, pno_encoding)
          params = [
            self.store_id,
            self.digest(pno),
            pno_encoding
          ]
          self.call_with_defaults(:has_account, *params)
        end

        # Create quantity and article number (i.e. the +articles+ argument for the
        # +activate_part+ and +credit_part+ function).
        #
        def self.create_article(quantity, article_id)
          [quantity, article_id]
        end
        def create_article(*args)
          self.class.create_article(*args)
        end

      end
    end
  end
end
