# frozen_string_literal: true
module Charts
  module Numbers
    class Builder
      extend Dry::Initializer
      include ::Command
      
      option :chart
      
      
      CALCULATORS = {
        'life_path' => ::Numbers::Calculators::LifePath,
        'expression' => ::Numbers::Calculators::Expression,
        'soul_urge' => ::Numbers::Calculators::SoulUrge,
        'personality' => ::Numbers::Calculators::Personality,
        'birthday' => ::Numbers::Calculators::Birthday
      }
      
      def run
        NumberType.all.each do |type|
          value = calculate(type.name)
          next if value.blank?
          number = Number.find_or_create_by(value:)
          next if number.blank? || !number.persisted?
          numerology_number = NumerologyNumber.find_or_create_by(number:, number_type: type)
          next if numerology_number.blank? || !numerology_number.persisted?
          chart.chart_numbers.find_or_create_by(numerology_number:)
        end
      end
      
      private
      
      def calculate(type)
        CALCULATORS[type].run(chart:)
      end
    end
  end
end