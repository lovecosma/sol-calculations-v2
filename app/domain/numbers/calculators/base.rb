# frozen_string_literal: true
module Numbers
  module Calculators
    class Base
      extend Dry::Initializer
      include Command
      option :chart
      
      PYTHAGOREAN_NUMEROLOGY = {
        'a' => 1, 'j' => 1, 's' => 1,
        'b' => 2, 'k' => 2, 't' => 2,
        'c' => 3, 'l' => 3, 'u' => 3,
        'd' => 4, 'm' => 4, 'v' => 4,
        'e' => 5, 'n' => 5, 'w' => 5,
        'f' => 6, 'o' => 6, 'x' => 6,
        'g' => 7, 'p' => 7, 'y' => 7,
        'h' => 8, 'q' => 8, 'z' => 8,
        'i' => 9, 'r' => 9
      }.freeze
      
      delegate :first_name, :middle_name, :last_name, :birthdate, :full_name, to: :chart
      
      def run
      	raise NotImplementedError, "Subclasses must implement the run method"
      end


      private
      def birthdate_to_numbers
        [birthdate.month,
        birthdate.day,
        birthdate.year].flat_map { |part| part.to_s.chars.map(&:to_i) }
      end
		
      def string_to_numbers(string)
        letter_array =  to_array_of_characters(string)
        letter_array.map do |letter|
          PYTHAGOREAN_NUMEROLOGY[letter]
        end
      end
      
      def to_array_of_characters(value)
        value.gsub(/\s+/, "").downcase.split("")
      end
		
      def reduce_to_single_digit(array_of_numbers)
        total = array_of_numbers.sum
        while total > 9 && ![11, 22, 33].include?(total)
          total = total.to_s.chars.map(&:to_i).sum
        end
        total
      end
      
      def filter_vowels(value)
        value.gsub(/[^aeiou]/i, '')
      end
      
      def raw_name
        full_name.gsub(/\s+/, "")
      end
      
      def filter_consonants(string)
        string.gsub(/[aeiou]/i, '')
      end
		end
  end
end
