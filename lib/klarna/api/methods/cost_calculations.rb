# encoding: utf-8

module Klarna
  module API
    module Methods
      module CostCalculations

        # Purpose: Obtain pclass values from Klarna.
        #
        # == Note:
        #
        #   This function is only to be used to obtain pclass values for stores ONE TIME ONLY.
        #   It is not allowed to use this function for continuous calculation of monthly costs or
        #   with every purchase in the checkout. The pclass values do NOT change.
        #
        def fetch_pclasses(currency_code)
          # params = [
          #   self.store_id,
          #   currency_code,
          #   self.digest(currency_code)
          # ]
          # self.call(:fetch_pclasses, *params)
          raise NotImplementedError
        end

        # Calculate monthly cost "in the most proper way".
        #
        def calculate_monthly_cost(sum, currency, pclass_id, flags = nil)
          # # TODO: OpenStruct this
          # pclasses = ::Klarna.store_pclasses[currency.to_s.underscore]
          # month_count = pclasses[pclass_id][:months]
          # monthly_fee = pclasses[pclass_id][:invoice_fee]
          # start_fee = pclasses[pclass_id][:start_fee]
          # rate = pclasses[pclass_id][:interest_rate]
          # type = pclasses[pclass_id][:type] # QUESTION: Where do I get this from - not in API-call.
          #
          # # TODO: Call Klarna and ask where I get "type" from - not with pclasses.
          # case type
          # when ::Klarna::API::PClassFlags::ANNUITY
          #   self.periodic_cost(sum, month_count, monthly_fee, start_fee, rate, currency, flags)
          # when ::Klarna::API::PClassFlags::DIVISOR
          #   self.monthly_cost(sum, month_count, monthly_fee, start_fee, rate, currency, flags)
          # else
          #   raise InvalidArgumentError, "Invalid Klarna campaign/pclass type: #{type.inspect}"
          # end
          raise NotImplementedError
        end

        # Calculate the monthly cost for goods which can be paid for by part payment.
        #
        def periodic_cost(sum, month_count, monthly_fee, start_fee, rate, currency, flags = nil)
          # daily_rate = self.calculate_daily_rate(rate)
          # monthly_payment = self.calculate_monthly_payment(sum + start_fee, daily_rate, month_count)
          # monthly_cost = monthly_payment + monthly_fee
          # monthly_cost.round
          raise NotImplementedError
        end

        # Calculate the monthly cost for account purchases.
        #
        def monthly_cost(sum, month_count, monthly_fee, start_fee, rate, currency, flags = nil)
          # interest_cost = self.calculate_interest_cost(sum, rate)
          # period_cost = (sum + interest_cost) / month_count
          # flags ||= ::Klarna::API::MonthlyCostFlags::LIMIT
          #
          # # TODO: Remove this line - after debugging.
          # ::Klarna.log [::Klarna::API::AVERAGE_INTEREST_PERIOD, calc_rate, interest_cost, period_cost].join(', ')
          #
          # monthly_cost = case flags
          #   when ::Klarna::API::MonthlyCostFlags::LIMIT
          #     period_cost
          #   when ::Klarna::API::MonthlyCostFlags::ACTUAL
          #     begin
          #       lowest_monthly_payment = ::Klarna::API::LOWEST_PAYMENT_BY_CURRENCY[currency]
          #     rescue
          #       raise ::Klarna::API::KlarnaStandardError,
          #       "No such currency: #{currency.inspect}. Valid currencies: SEK:1, NOK:2, EUR:3, DKK:4"
          #     end
          #     period_cost += monthly_fee
          #     (period_cost < lowest_monthly_payment) ? lowest_monthly_payment : period_cost
          #   else
          #     raise ::Klarna::API::KlarnaStandardError,
          #       "Invalid flag: #{flags.inspect}. Valid flags: LIMIT:0, ACTUAL:1"
          #       end
          # ::Klarna.log_result("Calculation: monthly_cost = %s") do
          #   self.round_up(monthly_cost, currency)
          # end
          raise NotImplementedError
        end

        protected

          def calculate_interest_cost(sum, rate)
            # rate *= 100.0 if rate < 100.0
            # calc_rate = (rate / 10000)
            # (::Klarna::API::AVERAGE_INTEREST_PERIOD / ::Klarna::API::DAYS_IN_A_YEAR) * calc_rate * sum
            raise NotImplementedError
          end

          def calculate_monthly_payment(sum, daily_rate, month_count)
            # sum = sum.to_double
            # total_dates = (month_count - 1) * 30
            # denominator = self.get_denominator(dailyrate, total_dates)
            # total_dates += 60
            # (dailyrate ** totdates) * sum / denominator
            raise NotImplementedError
          end

          def calculate_daily_rate(rate)
            # ((rate.to_decimal / 10000.0) + 1.0) ** (1 / ::Klarna::API::DAYS_IN_A_YEAR)
            raise NotImplementedError
          end

          def get_denominator(daily_rate, total_dates)
            # start_dates = 0.0
            # sum = 1.0
            # while total_dates > start_dates
            #   start_dates += 30
            #   sum += total_dates ** start_dates
            # end
            # sum
            raise NotImplementedError
          end

          def round_up(amount, currency)
            # divisor = currency == ::Klarna::API::Currencies::EUR ? 10.0 : 100.0
            # (((divisor / 2) + amount) / divisor) #.round
            raise NotImplementedError
          end

      end
    end
  end
end
