class ChartNumber < ApplicationRecord
	belongs_to :chart
	belongs_to :numerology_number
	
	delegate :number_type, to: :numerology_number
	delegate :number, to: :numerology_number
	
	delegate :name, to: :number_type
	delegate :value, to: :number

	delegate :description, to: :numerology_number
end
