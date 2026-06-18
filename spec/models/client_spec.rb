require 'rails_helper'

RSpec.describe Client, type: :model do
  describe "validations" do
    it "requires a name" do
      expect(build(:client, name: nil)).not_to be_valid
    end

    it "requires a unique email (case-insensitive)" do
      create(:client, email: "ann@example.com")
      expect(build(:client, email: "ANN@example.com")).not_to be_valid
    end

    it "rejects malformed emails" do
      expect(build(:client, email: "nope")).not_to be_valid
    end

    it "normalizes email to stripped lowercase so the unique index enforces case-insensitivity" do
      client = create(:client, email: "  Ann@Example.com  ")
      expect(client.email).to eq("ann@example.com")
    end
  end

  describe "associations" do
    it "has many providers through memberships" do
      client     = create(:client)
      provider_a = create(:provider)
      provider_b = create(:provider)
      create(:membership, provider: provider_a, client: client)
      create(:membership, provider: provider_b, client: client)

      expect(client.providers).to contain_exactly(provider_a, provider_b)
    end

    it "can hold a different plan with each provider" do
      client   = create(:client)
      basic_p  = create(:provider)
      premium_p = create(:provider)
      create(:membership, provider: basic_p,   client: client, plan: "basic")
      create(:membership, provider: premium_p, client: client, plan: "premium")

      plans = client.memberships.map { |m| [ m.provider, m.plan ] }
      expect(plans).to contain_exactly([ basic_p, "basic" ], [ premium_p, "premium" ])
    end
  end

  describe "journal entries" do
    it "returns entries oldest first" do
      client = create(:client)
      newer = create(:journal_entry, client: client, created_at: 1.hour.ago, body: "newer")
      older = create(:journal_entry, client: client, created_at: 2.days.ago, body: "older")

      expect(client.journal_entries.oldest_first).to eq([ older, newer ])
    end
  end
end
