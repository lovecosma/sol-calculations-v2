class ChartNumber < ApplicationRecord
	belongs_to :chart
	belongs_to :numerology_number
	
	has_many :descriptions, through: :numerology_number
	
	delegate :number_type, to: :numerology_number
	delegate :number, to: :numerology_number
	delegate :name, to: :number_type
	delegate :value, to: :number

	delegate :descriptions, to: :numerology_number


	
def short_general_description
	descriptions.find_by(context: 'general')&.short
end

end
