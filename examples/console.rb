require 'rubygems'
require 'bundler'
Bundler.require(:default)
require 'pp'

require File.expand_path("config/initializer", File.dirname(__FILE__)).to_s

# == Initialize a Klarna API-client.

Klarna.configure do |c|
  c.store_id = 2
  c.store_secret = 'lakrits'
  # c.mode = :production
  c.http_logging = true
end

begin
  @@klarna = ::Klarna::API::Client.new(::Klarna.store_id, ::Klarna.store_secret)
rescue Klarna::API::Errors::KlarnaCredentialsError => e
  puts e
rescue ::Klarna::API::Errors::KlarnaServiceError => e
  puts e
end

# puts ::Klarna::API::PNO_FORMATS[:SE].inspect
#
# print "SSN: "
# test_pno = gets.strip # "4304158399"
#
# puts "------------------------------"
# puts "eid: #{Klarna.store_id}"
# puts "secret: #{Klarna.store_secret}"
# puts "------------------------------"
# puts "pno: #{test_pno}"
#
# pno_secret = @@klarna.send(:digest, Klarna.store_id, test_pno, Klarna.store_secret)
#
# puts "pno_secret: #{pno_secret}"
# puts "------------------------------"
#
# puts @@klarna.get_addresses(test_pno, ::Klarna::API::PNO_FORMATS[:SE])

# ----------------------

order_items = []
order_items << @@klarna.make_goods(1, "ABC1", "T-shirt 1", 1.00 * 100, 25)
order_items << @@klarna.make_goods(1, "ABC2", "T-shirt 2", 7.00 * 100, 25)
order_items << @@klarna.make_goods(1, "ABC3", "T-shirt 3", 17.00 * 100, 25)

address = @@klarna.make_address("", "Junibackg. 42", "23634", "Hollviken", :SE, "076 526 00 00", "076 526 00 00", "karl.lidin@klarna.com")

invoice_no = @@klarna.add_transaction('USER-8203280154', 'ORDER-1', order_items, 0, 0, :NORMAL, '4304158399', "Karl", "Lidin", address, '85.230.98.196', :SEK, :SE, :SV, :SE)

pp "Invoice-no: #{invoice_no}"
