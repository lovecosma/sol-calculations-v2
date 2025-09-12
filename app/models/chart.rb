class Chart < ApplicationRecord

PYTHAGOREAN_NUMEROLOGY = {
	'a' => 1, 'j' => 1, 's' => 1,
	'b' => 2, 'k' => 2, 't' => 2,
	'c' => 3, 'l' => 3, 'u' => 3,
	'd' => 4, 'm' => 4, 'v' => 4,
	'e' => 5, 'n' => 5, 'w' => 5,
	'f' => 6, 'o' => 6, 'x' => 6,
	'g' => 7, 'p' => 7, 'y' => 7,
	'h' => 8, 'q' => 8, 'z' => 8,
	'i' => 9, 'r' => 9
}.freeze

validates :first_name, presence: true
validates :birth_date, presence: true
has_many :charts_numbers, dependent: :destroy
has_many :charts, through: :charts_numbers

after_save :build_numbers

private

def build_numbers
life_path = Numbers::LifePathCalculator.new(chart: self).calculate
end



end
