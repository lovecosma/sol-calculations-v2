# frozen_string_literal: true
module Charts
  module Numbers
    class Builder
      extend Dry::Initializer
      include Command
      
      option :chart
      
      
      CALCULATORS = {
        'life_path' => ::Numbers::Calculators::LifePath,
        'expression' => ::Numbers::Calculators::Expression
      }
      
      def run
        CALCULATORS.each_key do |type|
          value = calculate(type)
          number = Number.find_or_create_by(value:, name: type)
          ChartsNumber.find_or_create_by(chart:, number:)
        end
      end
      
      private
      
      def calculate(type)
        CALCULATORS[type].run(chart:)
      end
    end
  end
end