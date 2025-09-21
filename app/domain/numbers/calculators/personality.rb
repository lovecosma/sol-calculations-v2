# frozen_string_literal: true

module Numbers
module Calculators
class Personality < Base
	def run
		consonant_string = filter_consonants(raw_name)
		consonant_numbers = string_to_numbers(consonant_string)
		return if consonant_numbers.empty?
		reduce_to_single_digit(consonant_numbers)
	end
end
end
end
