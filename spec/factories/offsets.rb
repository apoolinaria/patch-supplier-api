FactoryBot.define do
  factory :offset do
    association :project
    sequence(:name) { |n| "Offset #{n}" }
    mass_g { 10_000_000 }
    price_cents_usd { 300_000 }
    retired { false }
  end
end
