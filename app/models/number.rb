class Number < ApplicationRecord
	has_many :numerology_numbers
	validates :value, presence: true, uniqueness: true, inclusion: { in: (1..31).to_a + [33]}
end
