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
        # Calculate all values first to avoid repeated queries
        calculated_values = calculate_all_values
        return if calculated_values.empty?

        # Batch fetch all needed records
        number_types = fetch_number_types
        numbers = fetch_or_create_numbers(calculated_values.values)
        numerology_numbers = fetch_or_create_numerology_numbers(calculated_values, number_types, numbers)

        # Create chart_numbers associations in batch
        create_chart_numbers(numerology_numbers)
      end

      private

      # Calculate all numerology values upfront
      def calculate_all_values
        CALCULATORS.each_with_object({}) do |(type_name, calculator), result|
          value = calculator.run(chart:)
          result[type_name] = value if value.present?
        end
      end

      # Preload all number types with a single query
      def fetch_number_types
        NumberType.all.index_by(&:name)
      end

      # Fetch or create all needed Number records efficiently
      def fetch_or_create_numbers(values)
        unique_values = values.compact.uniq

        # Find existing numbers in one query
        existing = Number.where(value: unique_values).index_by(&:value)

        # Create missing numbers
        missing_values = unique_values - existing.keys
        if missing_values.any?
          created = missing_values.map do |value|
            Number.create!(value: value)
          end
          created.each { |num| existing[num.value] = num }
        end

        existing
      end

      # Fetch or create all needed NumerologyNumber records efficiently
      def fetch_or_create_numerology_numbers(calculated_values, number_types, numbers)
        # Build lookup criteria
        criteria = calculated_values.map do |type_name, value|
          {
            number_type_id: number_types[type_name]&.id,
            number_id: numbers[value]&.id
          }
        end.compact

        # Find existing numerology_numbers in one query
        existing = NumerologyNumber
          .where(
            number_type_id: criteria.map { |c| c[:number_type_id] },
            number_id: criteria.map { |c| c[:number_id] }
          )
          .index_by { |nn| [nn.number_type_id, nn.number_id] }

        # Create missing numerology_numbers
        results = []
        calculated_values.each do |type_name, value|
          number_type = number_types[type_name]
          number = numbers[value]
          next unless number_type && number

          key = [number_type.id, number.id]
          numerology_number = existing[key]

          unless numerology_number
            numerology_number = NumerologyNumber.create!(
              number_type: number_type,
              number: number
            )
          end

          results << numerology_number
        end

        results
      end

      # Create ChartNumber associations efficiently
      def create_chart_numbers(numerology_numbers)
        return if numerology_numbers.empty?

        # Find existing chart_numbers
        existing_ids = chart.chart_numbers
          .where(numerology_number_id: numerology_numbers.map(&:id))
          .pluck(:numerology_number_id)
          .to_set

        # Only create missing associations
        new_associations = numerology_numbers.reject do |nn|
          existing_ids.include?(nn.id)
        end

        return if new_associations.empty?

        # Bulk insert using insert_all (Rails 6+)
        timestamp = Time.current
        records = new_associations.map do |nn|
          {
            chart_id: chart.id,
            numerology_number_id: nn.id,
            created_at: timestamp,
            updated_at: timestamp
          }
        end

        ChartNumber.insert_all(records) if records.any?
      end
    end
  end
end