class Number < ApplicationRecord
	validates :value, presence: true, uniqueness: true, inclusion: { in: (1..31).to_a + [33]}
end
