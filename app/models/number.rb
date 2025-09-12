class Number < ApplicationRecord
	has_many :charts_numbers, dependent: :destroy
	has_many :charts, through: :charts_numbers

	validates :value, presence: true
	validates :name, presence: true
end
