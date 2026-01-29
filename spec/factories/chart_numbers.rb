FactoryBot.define do
  factory :chart_number do
    association :chart

    transient do
      number_type { 'life_path' }
      value { rand(1..9) }
    end

    numerology_number do
      num_type = NumberType.find_or_create_by!(name: number_type)
      num = Number.find_or_create_by!(value: value)
      NumerologyNumber.find_or_create_by!(number: num, number_type: num_type)
    end

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
