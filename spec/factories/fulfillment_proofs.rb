FactoryBot.define do
  factory :fulfillment_proof do
    association :offset
    mass_g { 10_000_000 }
    sequence(:serial_number) { |n| "SERIAL-#{n}" }
  end
end
