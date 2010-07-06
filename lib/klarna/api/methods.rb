# encoding: utf-8

module Klarna
  module API
    module Methods

      autoload :Essential,    'klarna/api/methods/essential'
      autoload :Useful,       'klarna/api/methods/useful'
      autoload :Special,      'klarna/api/methods/special'
      autoload :Reservation,  'klarna/api/methods/reservation'

      include Essential
      include Useful
      include Special
      include Reservation

    end
  end
end