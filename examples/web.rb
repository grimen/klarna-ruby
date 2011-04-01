require 'rubygems'
require 'bundler'
Bundler.require(:default, :development)
require 'active_support/all'
require 'sinatra'
require 'sinatra/mapping'
require 'haml'

require File.join(File.dirname(__FILE__), 'initializer').to_s

# CAUTION: This code haven't been updated to reflect the library - TODO.

# == Initialize a Klarna API-client.

begin
  @@klarna = ::Klarna::API::Client.new(::Klarna.store_id, ::Klarna.store_secret)
rescue Klarna::API::Errors::KlarnaCredentialsError => e
  puts e
rescue ::Klarna::API::Errors::KlarnaServiceError => e
  puts e
end

# == Helpers to DRY up the views.

helpers do
  def partial(*args)
    locals = args.last.is_a?(Hash) ? args.pop : {}
    options = args.last.is_a?(Hash) ? args.pop : {}
    options.merge!(:layout => false)

    template_file = "_#{args.pop}"
    template_path = args.join('/')
    template = [template_path, template_file].join('/')

    haml(:"#{template}", options, locals)
  end

  def field(label, name, type, options = {})
    tag, type =
    case type.to_sym
    when :select
      [:select, nil]
    when :textarea
      [:textarea, nil]
    else
      [:input, type]
    end
    capture_haml do
      haml_tag(:label, label, :for => name)
    end <<
    capture_haml do
      haml_tag(tag, options.merge(:type => type, :name => name))
    end
  end

  def currency_selector(label = "Currency:")
    capture_haml do
      haml_tag(:label, label, :for => :currency)
    end <<
    capture_haml do
      haml_tag(:select, :name => :currency) do
        haml_tag(:option, "Sweden (SEK)", :value => 'SEK')
        haml_tag(:option, "Norway (NOK)", :value => 'NOK')
        haml_tag(:option, "Finland (EUR)", :value => 'EUR')
        haml_tag(:option, "Denmark (DKK)", :value => 'DKK')
        haml_tag(:option, "Germany (EUR)", :value => 'EUR')
      end
    end
  end

  def country_selector(label = "Country:", options = {})
    prefix = options[:prefix] || ""
    capture_haml do
      haml_tag(:label, label, :for => :country)
    end <<
    capture_haml do
      haml_tag(:select, :name => :"#{prefix}country") do
        haml_tag(:option, "Sweden (SE)", :value => 'SE')
        haml_tag(:option, "Norway (NO)", :value => 'NO')
        haml_tag(:option, "Finland (FI)", :value => 'FI')
        haml_tag(:option, "Denmark (DK)", :value => 'DK')
        haml_tag(:option, "Germany (DE)", :value => 'DE')
      end
    end
  end

  def ssn_encoding_selector(label = "SSN Encoding:")
    capture_haml do
      haml_tag(:label, label, :for => :pno_encoding)
    end <<
    capture_haml do
      haml_tag(:select, :name => :pno_encoding) do
        haml_tag(:option, "Swedish", :value => 'SV')
        haml_tag(:option, "Norwegian", :value => 'NO')
        haml_tag(:option, "Finnish", :value => 'FI')
        haml_tag(:option, "Danish", :value => 'DA')
        haml_tag(:option, "German", :value => 'DE')
      end
    end
  end

  def language_selector(label = "Language:")
    capture_haml do
      haml_tag(:label, label, :for => :language)
    end <<
    capture_haml do
      haml_tag(:select, :name => :language) do
        haml_tag(:option, "Swedish (SV)", :value => 'SV')
        haml_tag(:option, "Norwegian (NO)", :value => 'NO')
        haml_tag(:option, "Finnish (FI)", :value => 'FI')
        haml_tag(:option, "Danish (DA)", :value => 'DA')
        haml_tag(:option, "German (DE)", :value => 'DE')
      end
    end
  end

  def shipment_type_selector(label = "Shipment type:")
    capture_haml do
      haml_tag(:label, label, :for => :shipment_type)
    end <<
    capture_haml do
      haml_tag(:select, :name => :shipment_type) do
        haml_tag(:option, "Standard", :value => ::Klarna::API::ShipmentTypes::NORMAL)
        haml_tag(:option, "Express", :value => ::Klarna::API::ShipmentTypes::EXPRESS)
      end
    end
  end

  def submit_button(label = "Submit")
    capture_haml do
      haml_tag(:input, :type => :submit, :value => label)
    end
  end

  def button(label, link)
    capture_haml do
      haml_tag(:input, :type => 'button', :value => label, :onclick => link)
    end
  end

  def process_reservation_details(params)
    line_items = []
    line_items << ::Klarna.make_goods(params[:'product[0]_quantity'], params[:'product[0]_article_no]'], params[:'product[0]_title'], params[:'product[0]_price'], params[:'product[0]_vat'], params[:'product[0]_discout'])
    line_items << ::Klarna.make_goods(params[:'product[1]_quantity'], params[:'product[1]_article_no]'], params[:'product[1]_title'], params[:'product[1]_price'], params[:'product[1]_vat'], params[:'product[1]_discout'])

    delivery_address = ::Klarna::API.make_reservation_address(params[:delivery_first_name], params[:delivery_last_name], params[:delivery_street_address], params[:delivery_postal_code], params[:delivery_city], params[:delivery_country], params[:delivery_house_number])
    invoicing_address = ::Klarna::API.make_reservation_address(params[:invoicing_first_name], params[:invoicing_last_name], params[:invoicing_street_address], params[:invoicing_postal_code], params[:invoicing_city], params[:invoicing_country], params[:delivery_house_number])

    country = ::Klarna::API.id_for(:country, params[:currency])
    language = ::Klarna::API.id_for(:language, params[:language])
    currency = ::Klarna::API.id_for(:currency, params[:currency])

    client_ip = @env['REMOTE_ADDR']
    pclass = -1

    [line_items, delivery_address, invoicing_address, country, language, currency, client_ip, pclass]
  end
end

# == Mappings.

map :root, ""

# == General.

get '/' do
  haml :index
end
get '/favicon.ico' do
  nil
end
get '/:action' do
  haml params[:action].to_sym
end

# == Essential

# FIXME
get '/essential/calculate_monthly_cost' do
  @result = @@klarna.calculate_monthly_cost(params[:sum] * 100, params[:currency], params[:months], params[:month_fee])
  haml :"essential/calculate_monthly_cost/result"
end

# FIXME: Port to new API.
get '/essential/get_addresses' do
  @result = @@klarna.get_addresses(
      params[:pno],
      ::Klarna::API::PNO_FORMATS[:SE]
    )
  haml :"essential/get_addresses/result"
end

get '/essential/add_transaction' do
  goods_list = nil # ::Klarna.make_goods(params[:quantity], params[:article_no], t, price, vat, discount)
  address = ::Klarna::API.make_address(params[:care_of], params[:street_address], params[:postal_code], params[:city], params[:country], params[:phone], params[:mobile], params[:email])
  ip = @env['REMOTE_ADDR']
  password = nil
  new_password = nil
  currency = ::Klarna::API.id_for(:currency, params[:currency])
  country = ::Klarna::API.id_for(:country, params[:country])
  language = ::Klarna::API.id_for(:language, params[:language])

  @result = @@klarna.add_transaction(
      params[:invoicing],
      params[:order_id],
      goods_list,
      params[:shipping_fee],
      params[:shipment_type],
      params[:handling_fee],
      params[:pno],
      params[:first_name],
      params[:last_name],
      address,
      ip,
      currency,
      country,
      language
    )
  haml :"essential/add_transaction/result"
end

# == Invoicing

get '/invoicing/has_account' do
  @result = @@klarna.has_account?(params[:pno])
  haml :"essential/send_invoice/result"
end

get '/invoicing/activate_invoice' do
  @result = @@klarna.activate_invoice(params[:invoice_no])
  haml :"essential/activate_invoice/result"
end

get '/invoicing/credit_invoice' do
  @result = @@klarna.credit_invoice(params[:invoice_no], params[:credit_id])
  haml :"essential/credit_invoice/result"
end

get '/invoicing/delete_invoice' do
  @result = @@klarna.delete_invoice(params[:invoice_no])
  haml :"essential/delete_invoice/result"
end

get '/invoicing/return_amount' do
  @result = @@klarna.return_amount(params[:invoice_no], params[:amount], params[:vat])
  haml :"essential/return_amount/result"
end

get '/invoicing/email_invoice' do
  @result = @@klarna.email_invoice(params[:invoice_no])
  haml :"essential/email_invoice/result"
end

get '/invoicing/send_invoice' do
  @result = @@klarna.send_invoice(params[:invoice_no])
  haml :"essential/send_invoice/result"
end

# == Special

get '/special/update_charge_amount' do
  @result = @@klarna.update_charge_amount(params[:invoice_no], params[:charge_type], params[:new_amount])
  haml :"special/update_charge_amount/result"
end

get '/special/update_goods_quantity' do
  @result = @@klarna.update_goods_quantity(params[:invoice_no], params[:article_no], params[:quantity])
  haml :"special/update_goods_quantity/result"
end

get '/special/update_order_number' do
  @result = @@klarna.update_order_number(params[:invoice_no], params[:new_order_id])
  haml :"special/update_order_number/result"
end

get '/special/invoice_address' do
  @result = @@klarna.get_invoice_address(params[:invoice_no])
  haml :"special/invoice_address/result"
end

get '/special/invoice_amount' do
  @result = @@klarna.get_invoice_amount(params[:invoice_no])
  haml :"special/invoice_amount/result"
end

get '/special/is_invoice_paid' do
  @result = @@klarna.invoice_paid?(params[:invoice_no])
  haml :"special/is_invoice_paid/result"
end

get '/special/get_pclasses' do
  currency = ::Klarna::API.id_for(:currency, params[:currency])
  @result = @@klarna.get_pclasses(currency)
  haml :"special/get_pclasses/result"
end

# == Reservation

get '/reservation/reserve_amount' do
  line_items = []
  line_items << ::Klarna.make_goods(params[:'product[0]_quantity'], params[:'product[0]_article_no]'], params[:'product[0]_title'], params[:'product[0]_price'], params[:'product[0]_vat'], params[:'product[0]_discout'])
  line_items << ::Klarna.make_goods(params[:'product[1]_quantity'], params[:'product[1]_article_no]'], params[:'product[1]_title'], params[:'product[1]_price'], params[:'product[1]_vat'], params[:'product[1]_discout'])

  delivery_address = ::Klarna::API.make_reservation_address(params[:delivery_first_name], params[:delivery_last_name], params[:delivery_street_address], params[:delivery_postal_code], params[:delivery_city], params[:delivery_country], params[:delivery_house_number])
  invoicing_address = ::Klarna::API.make_reservation_address(params[:invoicing_first_name], params[:invoicing_last_name], params[:invoicing_street_address], params[:invoicing_postal_code], params[:invoicing_city], params[:invoicing_country], params[:delivery_house_number])

  country = ::Klarna::API.id_for(:country, params[:currency])
  language = ::Klarna::API.id_for(:language, params[:language])
  currency = ::Klarna::API.id_for(:currency, params[:currency])

  client_ip = @env['REMOTE_ADDR']
  pclass = -1

  # Q: What is order_id_X?
  @result = @@klarna.reserve_amount(params[:pno], params[:amount], line_items, params[:reference], params[:reference_id], params[:order_id_1], params[:order_id_1],
                          client_ip, delivery_address, invoicing_address, params[:email], params[:phone], params[:mobile],
                          currency, country, language, params[:pno_encoding], pclass, params[:annual_salary])
  haml :"special/reserve_amount/result"
end

get '/reservation/activate_reservation' do
  # Q: Same as reserve_amount...?
  line_items, delivery_address, invoicing_address, country, language, currency, client_ip, pclass = process_reservation_details(params)

  @result = @@klarna.activate_reservation(params[:pno], params[:amount], line_items, params[:reference], params[:reference_id], params[:order_id_1], params[:order_id_1],
                          client_ip, delivery_address, invoicing_address, params[:email], params[:phone], params[:mobile],
                          currency, country, language, params[:pno_encoding], pclass, params[:annual_salary])
  haml :"special/activate_reservation/result"
end

get '/reservation/cancel_reservation' do
  @result = @@klarna.cancel_reservation(params[:reservation_id])
  haml :"special/cancel_reservation/result"
end

get '/reservation/change_reservation' do
  @result = @@klarna.change_reservation(params[:reservation_id], params[:new_amount])
  haml :"special/change_reservation/result"
end

get '/reservation/split_reservation' do
  @result = @@klarna.split_reservation(params[:reservation_id], params[:split_amount], params[:order_id_1], params[:order_id_2])
  haml :"special/split_reservation/result"
end

get '/reservation/reserve_ocr_numbers' do
  @result = @@klarna.reserve_ocr_numbers(params[:ocr_count])
  haml :"special/reserve_ocr_numbers/result"
end
