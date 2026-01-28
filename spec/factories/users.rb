FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    password_confirmation { 'password123' }

    trait :with_charts do
      after(:create) do |user|
        create_list(:chart, 3, user: user)
      end
    end
  end
end
