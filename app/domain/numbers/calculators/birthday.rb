# frozen_string_literal: true

module Numbers
	module Calculators
		class Birthday < Base
			def run
				birthday_array = birthdate.day.to_s.chars.map(&:to_i)
				return if birthday_array.empty?
				reduce_to_single_digit(birthday_array)
			end
		end
	end
end
