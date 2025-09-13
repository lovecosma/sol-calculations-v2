# frozen_string_literal: true
module Numbers
  module Calculators
    class LifePath < Base
      def run
        return if birthdate_to_numbers.empty?
        reduce_to_single_digit(birthdate_to_numbers)
      end
    end
  end
end