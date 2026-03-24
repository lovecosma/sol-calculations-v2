class ChartNumber < ApplicationRecord
  belongs_to :chart, touch: true
  belongs_to :numerology_number

  scope :ordered, -> { joins(numerology_number: :number_type).order("number_types.position") }
  scope :displayable, -> {
    ordered
      .where.not(number_types: { name: NumberType::NON_DISPLAYABLE_TYPES })
      .where.not(numerology_numbers: { description: [ nil, "" ] })
      .where.not(numerology_numbers: { thumbnail_description: [ nil, "" ] })
  }

  delegate :number_type, to: :numerology_number
  delegate :number, to: :numerology_number

  delegate :name, to: :number_type
  delegate :value, to: :number

  delegate :description, :primary_title, to: :numerology_number
end
