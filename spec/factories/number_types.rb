FactoryBot.define do
  factory :number_type do
    name { 'life_path' }

    initialize_with { NumberType.find_or_create_by(name: name) }

    trait :expression do
      name { 'expression' }
    end

    trait :soul_urge do
      name { 'soul_urge' }
    end

    trait :personality do
      name { 'personality' }
    end

    trait :birthday do
      name { 'birthday' }
    end
  end
end
