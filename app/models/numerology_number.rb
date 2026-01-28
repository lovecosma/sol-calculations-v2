class NumerologyNumber < ApplicationRecord
	belongs_to :number
	belongs_to :number_type
	has_many :chart_numbers, dependent: :destroy

	# thumbnail_description is generated asynchronously by NumerologyNumbers::Descriptions::Builder
	# validates :thumbnail_description, presence: true

	delegate :value, to: :number
	delegate :name, to: :number_type
	
	
	def match_ids
	@match_ids ||= matches.map(&:to_i)
	end

	def mismatch_ids
	@misatch_ids ||= mismatches.map(&:to_i)
	end
end
