# encoding: utf-8
require 'xmlrpc/client'

module Klarna
  module API
    module Errors

      ERROR_CODES = {
        1103  => :estore_overrun,
        1104  => :estore_blacklisted,
        1999  => :misc_estore_error,
        2101  => :credit,
        2102  => :amount,
        2103  => :customer_credit_overrun,
        2104  => :blocked,
        2105  => :unpaid_bills,
        2106  => :customer_not_accepted,
        2107  => :customer_blacklisted,
        2201  => :pno,
        2202  => :invalid_pno,
        2203  => :pno_not_real_person,
        2204  => :dead,
        2205  => :under_aged,
        2206  => :customer_not_18,
        2301  => :no_such_person,
        2302  => :customer_missing,
        2303  => :no_such_customer,
        2304  => :unknown_customer,
        2305  => :bad_customer_password,
        2401  => :tno_not_found,
        2402  => :pin_error,
        2403  => :wrong_pin,
        2404  => :no_pin,
        2405  => :orgno,
        2999  => :misc_customer_error,
        3101  => :foreign_addr,
        3102  => :bad_addr,
        3103  => :bad_address,
        3104  => :postno,
        3105  => :bad_postno,
        3106  => :bad_name,
        3107  => :address,
        3108  => :no_address,
        3201  => :cellno,
        3202  => :telno,
        3203  => :email,
        3204  => :country,
        3205  => :city,
        3206  => :postno,
        3207  => :street,
        3208  => :client_ip,
        3209  => :proto_vsn,
        3210  => :goods_list,
        3211  => :artnos,
        3301  => :bad_name_and_address,
        3302  => :bad_last_name,
        3303  => :bad_first_name,
        3304  => :bad_first_name_and_last_name,
        3999  => :misc_submission_error,
        6101  => :orgno_pclass_not_allowed,
        6102  => :sum_low_for_pclass,
        6103  => :unknown_pclass,
        6104  => :not_annuity_pclass,
        6999  => :misc_pclass_error,
        7101  => :no_such_subscription,
        7102  => :not_unique_subscription_no,
        7103  => :terminated,
        7104  => :already_set,
        7105  => :need_email_addr,
        7999  => :misc_subscription_error,
        8101  => :unknown_invoice,
        8102  => :negative_invoice,
        8103  => :invoice_not_active,
        8104  => :invoice_bad_status,
        8105  => :invoice_is_passive,
        8106  => :invoice_is_archived,
        8107  => :invoice_is_suspect,
        8108  => :invoice_is_frozen,
        8109  => :invoice_is_pre_pay,
        8110  => :invoice_stale,
        8111  => :invoice_not_passive_or_frozen,
        8112  => :invoice_in_test_mode,
        8113  => :invoice_not_passive,
        8114  => :invno,
        8999  => :misc_invoice_error,
        9101  => :cno_already_in_use,
        9102  => :unknown_csid,
        9103  => :not_allowed_operation,
        9104  => :ip_from_wrong_country,
        9105  => :bad_type,
        9106  => :unknown_type,
        9107  => :bad_artnolist,
        9108  => :unknown_artno,
        9109  => :rno,
        9110  => :split,
        9111  => :bad_order_no,
        9112  => :bad_ocr,
        9113  => :unknown_estore,
        9114  => :invalid_estore_secret,
        9115  => :bad_module_vsn,
        9116  => :pno_encoding,
        9117  => :currency,
        9118  => :currency_country_pnoencoding,
        9119  => :timeout
      }.freeze

      class KlarnaStandardError < ::StandardError
        def initialize(message)
          ::Klarna.log message, :error
          super(message)
        end
      end

      class KlarnaArgumentError < ::ArgumentError
        def initialize(message)
          ::Klarna.log message, :error
          super(message)
        end
      end

      class KlarnaCredentialsError < KlarnaStandardError
      end

      class KlarnaServiceError < ::XMLRPC::FaultException
        alias :error_code :faultCode
        alias :error_message :faultString

        def initialize(error_code, error_key)
          localized_error_message = ::Klarna::API::Errors.error_message(error_key)
          message = ::Klarna.mode == :test ? "#{error_key} (#{[error_code, ERROR_CODES[error_code]].compact.join(' - ')})" : localized_error_message
          ::Klarna.log message, :error
          super(error_code, message)
        end

        def to_h
          {:error_code => self.error_code, :error_message => self.error_message}
        end
      end

      class << self

        # Lookup localized string value for a specified error/exception code or key.
        #
        def error_message(id_or_key)
          key = id_or_key.is_a?(Fixnum) ? ERROR_CODES[id_or_key] : id_or_key
          key
        end
        alias :localized_error_message :error_message

      end

    end
  end
end
