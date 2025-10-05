class NumerologyNumber < ApplicationRecord
	belongs_to :number
	belongs_to :number_type

	delegate :value, to: :number
	delegate :name, to: :number_type
	
	
	def match_ids
	@match_ids ||= matches.map(&:to_i)
	end

	def mismatch_ids
	@misatch_ids ||= mismatches.map(&:to_i)
	end
end
