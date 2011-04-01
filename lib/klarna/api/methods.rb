# encoding: utf-8
require 'klarna/api/methods/standard'
require 'klarna/api/methods/invoicing'
require 'klarna/api/methods/reservation'
require 'klarna/api/methods/cost_calculations'

module Klarna
  module API
    module Methods
      include ::Klarna::API::Methods::Standard
      include ::Klarna::API::Methods::Invoicing
      include ::Klarna::API::Methods::Reservation
      include ::Klarna::API::Methods::CostCalculations
    end
  end
end