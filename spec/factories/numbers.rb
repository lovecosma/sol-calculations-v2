FactoryBot.define do
  factory :number do
    sequence(:value) { |n| ((n - 1) % 9) + 1 }

    initialize_with { Number.find_or_create_by(value: value) }

    trait :master_number do
      value { [11, 22, 33].sample }
    end

    trait :specific_value do
      transient do
        num { 1 }
      end
      value { num }
    end
  end
end
