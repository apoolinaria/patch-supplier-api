FactoryBot.define do
  factory :payout do
    association :project
    association :offset
    amount_cents_usd { 300_000 }
    status { "pending_approval" }
  end
end
