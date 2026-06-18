FactoryBot.define do
  factory :journal_entry do
    client
    body { "Felt good today." }
  end
end
