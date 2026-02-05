# frozen_string_literal: true

module Numbers
	module Calculators
		class Birthday < Base
			def run
				return if birthdate.blank?
				birthdate.day
			end
		end
	end
end
