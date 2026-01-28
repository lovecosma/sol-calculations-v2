FactoryBot.define do
  factory :chart_number do
    association :chart
    number_type { 'life_path' }
    value { rand(1..9) }

    trait :life_path do
      number_type { 'life_path' }
    end

    trait :expression do
      number_type { 'expression' }
    end

    trait :soul_urge do
      number_type { 'soul_urge' }
    end

    trait :personality do
      number_type { 'personality' }
    end
  end
end
