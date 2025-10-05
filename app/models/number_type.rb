class NumberType < ApplicationRecord
HUMAN_NAMES = {
	'life_path' => 'Life Path',
	'expression' => 'Expression',
	'soul_urge' => 'Soul Urge',
	'personality' => 'Personality',
	'birthday' => 'Birthday'
}.freeze
validates :name, presence: true, uniqueness: true, inclusion: { in: HUMAN_NAMES.keys }

end
