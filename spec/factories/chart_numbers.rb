FactoryBot.define do
  factory :chart_number do
    association :chart

    transient do
      number_type { 'life_path' }
      value { rand(1..9) }
    end

    after(:build) do |chart_number, evaluator|
      # Efficiently create the association chain: NumberType -> Number -> NumerologyNumber
      chart_number.numerology_number ||= begin
        num_type = NumberType.find_or_create_by!(name: evaluator.number_type)
        num = Number.find_or_create_by!(value: evaluator.value)
        NumerologyNumber.find_or_create_by!(number: num, number_type: num_type)
      end
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

    trait :birthday do
      number_type { 'birthday' }
      value { rand(1..31) }
    end
  end
end
