FactoryBot.define do
  factory :project do
    sequence(:name) { |n| "Project #{n}" }
    sequence(:api_key) { |n| "api_key_#{n}" }
  end
end
