# encoding: utf-8

module Klarna
  module API
    module Methods
      module Essential

        # Calculate monthly cost "in the most proper way".
        #
        def calculate_monthly_cost(sum, currency, pclass_id, flags = nil)
          # TODO: OpenStruct this
          pclasses = ::Klarna.pclasses[currency.to_s.underscore]
          month_count = pclasses[pclass_id][:months]
          monthly_fee = pclasses[pclass_id][:invoice_fee]
          start_fee = pclasses[pclass_id][:start_fee]
          rate = pclasses[pclass_id][:interest_rate]
          type = pclasses[pclass_id][:type] # QUESTION: Where do I get this from - not in API-call.

          # TODO: Call Klarna and ask where I get "type" from - not with pclasses.
          case type
          when ::Klarna::API::PClassFlags::ANNUITY
            self.periodic_cost(sum, month_count, monthly_fee, start_fee, rate, currency, flags)
          when ::Klarna::API::PClassFlags::DIVISOR
            self.monthly_cost(sum, month_count, monthly_fee, start_fee, rate, currency, flags)
          else
            raise InvalidArgumentError, "Invalid Klarna campaign/pclass type: #{type.inspect}"
          end
        end

        # Calculate the monthly cost for goods which can be paid for by part payment.
        #
        def periodic_cost(sum, month_count, monthly_fee, start_fee, rate, currency, flags = nil)
          daily_rate = self.calculate_daily_rate(rate)
          monthly_payment = self.calculate_monthly_payment(sum + start_fee, daily_rate, month_count)
          monthly_cost = monthly_payment + monthly_fee
          monthly_cost.round
        end

        # Calculate the monthly cost for account purchases.
        #
        def monthly_cost(sum, month_count, monthly_fee, start_fee, rate, currency, flags = nil)
          interest_cost = self.calculate_interest_cost(sum, rate)
          period_cost = (sum + interest_cost) / month_count
          flags ||= ::Klarna::API::MonthlyCostFlags::LIMIT

          # TODO: Remove this line - after debugging.
          ::Klarna.log [::Klarna::API::AVERAGE_INTEREST_PERIOD, calc_rate, interest_cost, period_cost].join(', ')

          monthly_cost = case flags
            when ::Klarna::API::MonthlyCostFlags::LIMIT
              period_cost
            when ::Klarna::API::MonthlyCostFlags::ACTUAL
              begin
                lowest_monthly_payment = ::Klarna::API::LOWEST_PAYMENT_BY_CURRENCY[currency]
              rescue
                raise ::Klarna::API::KlarnaStandardError,
                "No such currency: #{currency.inspect}. Valid currencies: SEK:1, NOK:2, EUR:3, DKK:4"
              end
              period_cost += monthly_fee
              (period_cost < lowest_monthly_payment) ? lowest_monthly_payment : period_cost
            else
              raise ::Klarna::API::KlarnaStandardError,
                "Invalid flag: #{flags.inspect}. Valid flags: LIMIT:0, ACTUAL:1"
                end
          ::Klarna.log_result("Calculation: monthly_cost = %s") do
            self.round_up(monthly_cost, currency)
          end
        end

        # Retrieve a customer’s address(es). Using this, the customer is not required to enter
        # any information – only confirm the one presented to him/her.
        # Can also be used for companies: If the customer enters a company number,
        # it will return all the addresses where the company is registered at.
        #
        # == Note:
        #
        #   ONLY allowed to be used for Swedish persons with the following conditions:
        #
        #     * It can be only used if invoice or part payment is the default payment method
        #     * It has to disappear if the customer chooses another payment method
        #     * The button is not allowed to be called get address ("hämta adress"), but continue ("fortsätt")
        #       or it can be picked up automatically when all the numbers have been typed.
        #
        #   In the other Nordic countries you will have to have input fields for name, last name, street name,
        #   zip code and city so that the customer can enter this information by himself.
        #
        def get_addresses(pno, pno_encoding, address_type = ::Klarna::API::AddressFormats::NEW)
          params = [
            pno,
            self.store_id,
            self.digest(pno),
            pno_encoding,
            address_type
          ]
          self.call_with_defaults(:get_addresses, *params)
        end

        # Create an invoice.
        #
        def add_transaction(store_user_id, order_id, goods_list, shipment_type, shipping_fee,
                            handling_fee, pno, first_name, last_name, address, client_ip,
                            currency, country, language, pno_encoding, pclass, annual_salary = nil,
                            password = nil, ready_date = nil, comment = nil, rand_string = nil, flags = nil, new_password = nil)
          params = [
            self.store_id,
            store_user_id,
            self.digest(goods_list.collect { |g| g[:goods][:title] }.join(':')),
            order_id,
            goods_list,
            shipping_fee,
            shipment_type,
            handling_fee,
            pno,
            first_name,
            last_name,
            address,
            password,
            client_ip,
            new_password,
            flags,
            comment.to_s,
            ready_date,
            rand_string,
            currency,
            country,
            language,
            pno_encoding,
            pclass,
            annual_salary
          ]
          self.call_with_defaults(:add_transaction, *params)
        end
        alias :create_invoice :add_transaction

        # Create addresses (i.e. the +address+ argument to the +add_transaction+ method).
        #
        def self.create_address(co_address, street_address, zip, city, country, phone, cell_phone, email)
          {
            :careof  => co_address,
            :street  => street_address,
            :postno  => zip,
            :city    => city,
            :country => ::Klarna::API.country_id_for(country),
            :telno   => phone,
            :cellno  => cell_phone,
            :email   => email
          }.with_indifferent_access
        end
        def create_address(*args)
          self.class.create_address(*args)
        end

        # Create an inventory (i.e. the +goods_list+ argument) to the +add_transaction+ function.
        #
        # == Flags:
        #
        # Argument +flags+ can be used to set the precision of the article, to indicate a shipment
        # or a fee or sending the price with VAT.
        #
        # By using either +PRINT_1000+, +PRINT_100+, or +PRINT_10+, the +flags+
        # function can be used to set article quantity (+quantity+). Unit is either +1/10+, +1/100+
        # or +1/1000+. This is useful for goods measured in meters or kilograms, rather than number of items.
        #
        # By using the +IS_SHIPMENT+ or +IS_HANDLING+ flags a shipping or handling fee can
        # be applied. The fees are sent excluding VAT with the arguments +shipping_fee+ or +handling_fee+.
        #
        # By using the +INC_VAT+ flag, you can send the price including VAT.
        #
        # == Note:
        #
        #   If you are implementing sales with Euros, use the function mk_goods_flags instead
        #   since using this method can result in round off problems. With +mk_goods_flags+ you
        #   are able to send the price with VAT.
        #
        def self.create_goods(quantity, article_id, title, price, vat, discount = nil, flags = nil)
          goods = {
            :goods => {
              :artno     => article_id,
              :title     => title,
              :price     => price,
              :vat       => vat,
              :discount  => discount,
            },
            :qty => quantity
          }
          goods[:goods].merge(:flags => flags) if flags.present?
          goods.with_indifferent_access
        end
        def create_goods(*args)
          self.class.create_address(*args)
        end

        protected

          def calculate_interest_cost(sum, rate)
            rate *= 100.0 if rate < 100.0
            calc_rate = (rate / 10000)
            (::Klarna::API::AVERAGE_INTEREST_PERIOD / ::Klarna::API::DAYS_IN_A_YEAR) * calc_rate * sum
          end

          def calculate_monthly_payment(sum, daily_rate, month_count)
            sum = sum.to_double
            total_dates = (month_count - 1) * 30
            denominator = self.get_denominator(dailyrate, total_dates)
            total_dates += 60
            (dailyrate ** totdates) * sum / denominator
          end

          def calculate_daily_rate(rate)
            ((rate.to_decimal / 10000.0) + 1.0) ** (1 / ::Klarna::API::DAYS_IN_A_YEAR)
          end

          def get_denominator(daily_rate, total_dates)
            start_dates = 0.0
            sum = 1.0
            while total_dates > start_dates
              start_dates += 30
              sum += total_dates ** start_dates
            end
            sum
          end

          def round_up(amount, currency)
            divisor = currency == ::Klarna::API::Currencies::EUR ? 10.0 : 100.0
            (((divisor / 2) + amount) / divisor) #.round
          end

      end
    end
  end
end
