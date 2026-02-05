# frozen_string_literal: true
module Charts
  module Numbers
    class Builder
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
        calculated_values = calculate_all_values
        return if calculated_values.empty?

        numerology_numbers = fetch_numerology_numbers(calculated_values)
        create_chart_numbers(numerology_numbers)
      end

      private

      def calculate_all_values
        CALCULATORS.each_with_object({}) do |(type_name, calculator), result|
          value = calculator.run(chart:)
          result[type_name] = value if value.present?
        end
      end

      def fetch_numerology_numbers(calculated_values)
        number_types = NumberType.where(name: calculated_values.keys).index_by(&:name)
        numbers = Number.where(value: calculated_values.values).index_by(&:value)

        pairs = calculated_values.filter_map do |type_name, value|
          type_id = number_types[type_name]&.id
          num_id = numbers[value]&.id
          [type_id, num_id] if type_id && num_id
        end

        return [] if pairs.empty?

        conditions = pairs.map { "(number_type_id = ? AND number_id = ?)" }.join(" OR ")
        NumerologyNumber.where(conditions, *pairs.flatten)
      end

      def create_chart_numbers(numerology_numbers)
        return if numerology_numbers.empty?

        existing_ids = chart.chart_numbers
          .where(numerology_number_id: numerology_numbers.map(&:id))
          .pluck(:numerology_number_id)
          .to_set

        new_ids = numerology_numbers.map(&:id) - existing_ids.to_a
        return if new_ids.empty?

        timestamp = Time.current
        records = new_ids.map do |nn_id|
          {
            chart_id: chart.id,
            numerology_number_id: nn_id,
            created_at: timestamp,
            updated_at: timestamp
          }
        end

        ChartNumber.insert_all(records)
      end
    end
  end
end