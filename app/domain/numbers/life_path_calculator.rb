# frozen_string_literal: true
module Numbers
	class LifePathCalculator < BaseCalculator
		NUMBER_TYPE = 'life_path'
		def calculate
		total = date_to_numbers.sum
			while total > 9 && ![11, 22, 33].include?(total)
				total = total.to_s.chars.map(&:to_i).sum
			end
		total
		end
	end
end