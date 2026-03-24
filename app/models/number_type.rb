class NumberType < ApplicationRecord
  has_many :numerology_numbers

  NON_DISPLAYABLE_TYPES = %w[personal_year].freeze

  HUMAN_NAMES = {
    "life_path" => "Life Path",
    "expression" => "Expression",
    "soul_urge" => "Soul Urge",
    "personality" => "Personality",
    "birthday" => "Birthday",
    "personal_year" => "Personal Year"
  }.freeze
  validates :name, presence: true, uniqueness: true, inclusion: { in: HUMAN_NAMES.keys }
end
