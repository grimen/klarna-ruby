# encoding: utf-8

require 'rubygems'
require 'bundler'
Bundler.require(:default)
require 'active_support/all'
require 'pp'

require File.expand_path("config/initializer", File.dirname(__FILE__)).to_s

# == Initialize a Klarna API-client.

Klarna.configure do |c|
  c.store_id = ENV['KLARNA_ESTORE_ID'].presence
  c.store_secret = ENV['KLARNA_ESTORE_SECRET'].presence
  c.mode = ENV['KLARNA_MODE'].presence
  c.http_logging = true
end

begin
  @@klarna = ::Klarna::API::Client.new(::Klarna.store_id, ::Klarna.store_secret)
rescue Klarna::API::Errors::KlarnaCredentialsError => e
  puts e
rescue ::Klarna::API::Errors::KlarnaServiceError => e
  puts e
end

@@klarna.client_ip = '192.168.0.196'

puts @@klarna.endpoint_uri.inspect

puts ::Klarna::API::PNO_FORMATS[:SE].inspect

print "SSN: "
test_pno = "820328-0154" # "4304158399" # gets.strip # "4304158399"

puts "------------------------------"
puts "eid: #{Klarna.store_id}"
puts "secret: #{Klarna.store_secret}"
puts "------------------------------"
puts "pno: #{test_pno}"

pno_secret = @@klarna.send(:digest, Klarna.store_id, test_pno, Klarna.store_secret)

puts "pno_secret: #{pno_secret}"
puts "------------------------------"

puts @@klarna.get_addresses(test_pno, ::Klarna::API::PNO_FORMATS[:SE])

# ----------------------

order_items = []
order_items << @@klarna.make_goods(1, "ABC1", "T-shirt 1", 1.00 * 100, 25)
# order_items << @@klarna.make_goods(1, "ABC2", "T-shirt 2", 7.00 * 100, 25)
# order_items << @@klarna.make_goods(1, "ABC3", "T-shirt 3", 17.00 * 100, 25)

#address = @@klarna.make_address("", "Junibackg. 42", "23634", "Hollviken", :SE, "076 526 00 00", "076 526 00 00", "karl.lidin@klarna.com")
address = @@klarna.make_address("", "Sollentunavägen 68", "18743", "Täby", :SE, "0702167225", "0702167225", "grimen@gmail.com")

# invoice_no = @@klarna.add_transaction("USER-#{test_pno}", 'ORDER-1', order_items, 0, 0, :NORMAL, test_pno, "Karl", "Lidin", address, '85.230.98.196', :SEK, :SE, :SV, :SE) #, nil, nil, nil, nil, nil, nil, nil, :TEST_MODE => true)
invoice_no = @@klarna.add_transaction("USER-#{test_pno}", 'ORDER-1', order_items, 0, 0, :NORMAL, test_pno, "Jonas", "Grimfelt", address, '85.230.98.196', :SEK, :SE, :SV, :SE) #, nil, nil, nil, nil, nil, nil, nil, :TEST_MODE => true)

pp "Invoice-no: #{invoice_no}"

# FIXME: Since Klarna API changed this fails even with the TEST_MODE (2) flag set.

# invoice_url = @@klarna.activate_invoice(invoice_no)

# pp "Invoice-URL: #{invoice_url}"


