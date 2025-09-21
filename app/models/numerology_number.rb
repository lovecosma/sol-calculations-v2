class NumerologyNumber < ApplicationRecord
	belongs_to :number
	belongs_to :number_type
	has_many :descriptions, dependent: :destroy

	delegate :value, to: :number
	delegate :name, to: :number_type
end
