 FactoryBot.define do
  factory :chart_number do
    chart
    numerology_number

    trait :life_path do
      association :numerology_number, :life_path
    end

    trait :expression do
      association :numerology_number, :expression
    end

    trait :soul_urge do
      association :numerology_number, :soul_urge
    end

    trait :personality do
      association :numerology_number, :personality
    end

    trait :birthday do
      association :numerology_number, :birthday
    end
  end
end
