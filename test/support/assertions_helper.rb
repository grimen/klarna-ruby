# encoding: utf-8
require 'active_support/test_case'

module Klarna
  module AssertionsHelper
    def assert_not(assertion)
      assert !assertion
    end

    def assert_blank(assertion)
      assert assertion.blank?
    end

    def assert_not_blank(assertion)
      assert !assertion.blank?
    end
    alias :assert_present :assert_not_blank

    # Execute the block setting the given values and restoring old values after
    # the block is executed.
    def swap(object, new_values)
      old_values = {}
      new_values.each do |key, value|
        old_values[key] = object.send key
        object.send :"#{key}=", value
      end
      yield
    ensure
      old_values.each do |key, value|
        object.send :"#{key}=", value
      end
    end

    def expose_protected_methods_in(*args)
      args.each do |klass|
        klass.send(:public, *[klass.protected_instance_methods, klass.private_instance_methods].flatten)
      end
    end
  end
end
