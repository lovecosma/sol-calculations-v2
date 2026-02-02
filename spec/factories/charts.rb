FactoryBot.define do
  factory :chart do
    association :user
    full_name { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
    birthdate { Faker::Date.between(from: 60.years.ago, to: 18.years.ago) }

    trait :with_middle_name do
      full_name { "#{Faker::Name.first_name} #{Faker::Name.middle_name} #{Faker::Name.last_name}" }
    end

    trait :invalid do
      full_name { '' }
      birthdate { nil }
    end

    # Note: Chart#build_numbers automatically creates chart_numbers after save,
    # but only if NumberTypes exist in the database. This trait manually creates
    # chart_numbers for tests that need specific, predictable values.
    trait :with_chart_numbers do
      after(:create) do |chart|
        # Clear any auto-generated chart_numbers to ensure predictable test data
        chart.chart_numbers.destroy_all

        create(:chart_number, chart: chart, number_type: 'life_path', value: 5)
        create(:chart_number, chart: chart, number_type: 'expression', value: 3)
      end
    end
  end
end
