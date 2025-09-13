# frozen_string_literal: true

module Numbers
	module Calculators
		class Expression < Base
		
			def run
				name_numbers = name_to_numbers(full_name)
				return if name_numbers.empty?
				reduce_to_single_digit(name_numbers)
			end
		end
	end
end
