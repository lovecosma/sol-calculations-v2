# frozen_string_literal: true

module Numbers
  module Calculators
    class PersonalYear < Base
      def run
        digits = [ birthdate.month, birthdate.day, Date.today.year ]
          .flat_map { |part| part.to_s.chars.map(&:to_i) }
        reduce_to_single_digit_strict(digits)
      end
    end
  end
end
