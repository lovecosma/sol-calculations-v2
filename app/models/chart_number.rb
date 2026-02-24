class ChartNumber < ApplicationRecord
	belongs_to :chart, touch: true
	belongs_to :numerology_number

	scope :ordered, -> { joins(numerology_number: :number_type).order('number_types.position') }

	delegate :number_type, to: :numerology_number
	delegate :number, to: :numerology_number

	delegate :name, to: :number_type
	delegate :value, to: :number

	delegate :description, :primary_title, to: :numerology_number
end
