FactoryBot.define do
  factory :order do
    association :offset
    mass_g { 10_000_000 }
  end
end
