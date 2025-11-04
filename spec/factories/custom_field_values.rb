FactoryBot.define do
  factory :custom_field_value do
    association :building
    association :custom_field
    value { "sample value" }
  end
end
