FactoryBot.define do
  factory :chart, class: UserChart do
    user
    full_name { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
    birthdate { Faker::Date.between(from: 60.years.ago, to: 18.years.ago) }

    trait :with_middle_name do
      full_name { "#{Faker::Name.first_name} #{Faker::Name.middle_name} #{Faker::Name.last_name}" }
    end

    trait :invalid do
      full_name { '' }
      birthdate { nil }
    end

    trait :with_chart_numbers do
      after(:create) do |chart|
        life_path_num = create(:numerology_number, :life_path, number: create(:number, value: 5))
        expression_num = create(:numerology_number, :expression, number: create(:number, value: 3))

        create(:chart_number, chart: chart, numerology_number: life_path_num)
        create(:chart_number, chart: chart, numerology_number: expression_num)
      end
    end
  end
end
