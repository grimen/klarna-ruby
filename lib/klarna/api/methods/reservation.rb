# encoding: utf-8

module Klarna
  module API
    module Methods
      module Reservation

        # Reserve a purchase amount for a specific customer. The reservation is valid, by default, for 7 days.
        #
        def reserve_amount(pno_or_cellphone, amount, goods_list, reference, reference_code, order_id_1, order_id_2,
                            client_ip, shipping_address, invoicing_address, email, phone, cell_phone,
                            currency_code, country_code, language_code, pno_encoding, pclass, annual_salary = nil, flags = nil)
          params = [
            pno_or_cellphone,
            amount,
            reference,
            reference_code,
            order_id_1,
            order_id_2,
            shipping_address,
            invoicing_address,
            email,
            phone,
            cell_phone,
            client_ip,
            flags,
            currency_code,
            country_code,
            language_code,
            self.store_id,
            self.digest(pno_or_cellphone, amount),
            pno_encoding,
            (pclass || KRED_DEFAULT_PCLASS),
            (annual_salary || KRED_DEFAULT_YSALARY),
            goods_list
          ]
          self.call_with_defaults(:reserve_amount, *params)
        end
        alias :add_sms_transaction :reserve_amount # NOTE: Pass cellphone no. instead of Pno for SMS payments.

        # Activate purchases which have been previously reserved with the reserve_amount function.
        #
        def activate_reservation(reservation_id, pno, ocr, goods_list, reference, reference_code, order_id_1, order_id_2,
                                 client_ip, shipping_address, invoicing_address, shipment_type, email, phone, cell_phone,
                                 currency_code, country_code, language_code, pno_encoding, pclass, annual_salary = nil, flags = nil)
          params = [
            reservation_id,
            pno,
            (ocr || KRED_DEFAULT_OCR),
            goods_list,
            reference,
            reference_code,
            order_id_1,
            order_id_2,
            shipping_address,
            invoicing_address,
            shipment_type,
            email,
            phone,
            cell_phone,
            client_ip,
            flags,
            currency_code,
            country_code,
            language_code,
            self.store_id,
            self.digest(pno, goods_list),
            pno_encoding,
            (pclass || KRED_DEFAULT_PCLASS),
            (annual_salary || KRED_DEFAULT_YSALARY)
          ]
          self.call_with_defaults(:activate_reservation, *params)
        end

        # Cancel a reservation.
        #
        def cancel_reservation(reservation_id)
          params = [
            reservation_id,
            self.store_id,
            self.digest(reservation_id)
          ]
          self.call_with_defaults(:cancel_reservation, *params)
        end

        # Split a reservation due to for example outstanding articles.
        #
        def split_reservation(reservation_id, split_amount, order_id_1, order_id_2, flags = nil)
          params = [
            reservation_id,
            split_amount,
            order_id_1,
            order_id_2,
            flags.to_i,
            self.store_id,
            self.digest(reservation_id, split_amount)
          ]
          self.call_with_defaults(:split_reservation, *params)
        end

        # Change a reservation.
        #
        def change_reservation(reservation_id, new_amount)
          params = [
            reservation_id,
            new_amount,
            self.store_id,
            self.digest(reservation_id, new_amount)
          ]
          self.call_with_defaults(:change_reservation, *params)
        end

        # Reserves one or more OCR numbers for your store.
        #
        def reserve_ocr_numbers(number_of_ocrs)
          params = [
            number_of_ocrs,
            self.store_id,
            self.digest(number_of_ocrs)
          ]
          self.call_with_defaults(:reserve_ocr_nums, *params)
        end

        # Create addresses for arguments such as the +activate_reservation+ function.
        #
        def self.create_reservation_address(first_name, last_name, street_address, zip, city, country_code, house_number = nil)
          {
            :fname        => first_name,
            :lname        => last_name,
            :street       => street_address,
            :zip          => zip,
            :city         => city,
            :country      => ::Klarna::API.country_id_for(country_code),
            :house_number => house_number
          }.with_indifferent_access
        end
        def create_reservation_address(*args)
          self.class.create_reservation_address(*args)
        end

      end
    end
  end
end
