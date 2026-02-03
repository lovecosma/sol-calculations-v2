FactoryBot.define do
  factory :numerology_number do
    number
    number_type

    primary_title { nil }
    secondary_titles { nil }
    thumbnail_description { nil }
    core_essence { nil }
    strengths { nil }
    challenges { nil }
    matches { nil }
    mismatches { nil }
    description { nil }

    initialize_with do
      NumerologyNumber.find_or_create_by(
        number: number,
        number_type: number_type
      )
    end

    trait :with_description do
      primary_title { "The Leader" }
      secondary_titles { ["The Pioneer", "The Initiator"] }
      thumbnail_description { "A natural leader with strong independence and initiative." }
      core_essence { ["Natural leadership", "Independent thinking"] }
      strengths { ["Confident", "Innovative", "Courageous"] }
      challenges { ["Impatient", "Stubborn", "Overly competitive"] }
      matches { [3, 5, 7] }
      mismatches { [2, 4, 8] }
      description { "This number embodies leadership and independence. People with this number are natural pioneers who forge their own path." }
    end

    trait :life_path do
      association :number_type, factory: [:number_type, :life_path]
    end

    trait :expression do
      association :number_type, :expression
    end

    trait :soul_urge do
      association :number_type, :soul_urge
    end

    trait :personality do
      association :number_type, :personality
    end

    trait :birthday do
      association :number_type, :birthday
    end
  end
end
