class NumerologyNumber < ApplicationRecord
	belongs_to :number
	belongs_to :number_type

	delegate :value, to: :number
	delegate :name, to: :number_type
end
