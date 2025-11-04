FactoryBot.define do
  factory :building do
    association :client
    address { Faker::Address.street_address }
    state { Faker::Address.state_abbr }
    zip { Faker::Address.zip_code }
  end
end
