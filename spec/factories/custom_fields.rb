FactoryBot.define do
  factory :custom_field do
    association :client
    name { Faker::Lorem.word }

    trait :number do
      field_type { :number }
    end

    trait :freeform do
      field_type { :freeform }
    end

    trait :enum_type do
      field_type { :enum_type }
      enum_options { ["Option A", "Option B", "Option C"] }
    end
  end
end
