# frozen_string_literal: true

module Numbers
	module Calculators
		class SoulUrge < Base
			def run
				vowel_string = filter_vowels(raw_name)
				vowel_numbers = string_to_numbers(vowel_string)
				return if vowel_numbers.empty?
				reduce_to_single_digit(vowel_numbers)
			end
		end
	end
end
