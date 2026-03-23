class ChartNumber < ApplicationRecord
  belongs_to :chart, touch: true
  belongs_to :numerology_number

  NON_DISPLAYABLE_TYPES = %w[personal_year].freeze

  scope :ordered, -> { joins(numerology_number: :number_type).order("number_types.position") }
  scope :displayable, ->(excluded_types = NON_DISPLAYABLE_TYPES) {
    ordered
      .where.not(number_types: { name: excluded_types })
      .where.not(numerology_numbers: { description: [nil, ""] })
      .where.not(numerology_numbers: { thumbnail_description: [nil, ""] })
  }

  delegate :number_type, to: :numerology_number
  delegate :number, to: :numerology_number

  delegate :name, to: :number_type
  delegate :value, to: :number

  delegate :description, :primary_title, to: :numerology_number
end
