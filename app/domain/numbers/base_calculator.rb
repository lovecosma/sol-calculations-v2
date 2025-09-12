# frozen_string_literal: true

module Numbers
	class BaseCalculator
		extend Dry::Initializer
		option :chart
		delegate :first_name, :middle_name, :last_name, :birth_date, to: :chart

	
	private
		def date_to_numbers
			[birth_date.month,
			 birth_date.day,
			 birth_date.year].flat_map { |part| part.to_s.chars.map(&:to_i) }
		end
	end
end
