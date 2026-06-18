FactoryBot.define do
  factory :membership do
    provider
    client
    plan { "basic" }
  end
end
