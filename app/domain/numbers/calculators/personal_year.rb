# frozen_string_literal: true

module Numbers
  module Calculators
    class PersonalYear < Base
      option :year, Types::Coercible::Integer, default: proc { Date.today.year }

      def run
        return if birthdate.blank?

        digits = [ birthdate.month, birthdate.day, year ]
          .flat_map { |part| part.to_s.chars.map(&:to_i) }
        reduce_to_single_digit_strict(digits)
      end
    end
  end
end
