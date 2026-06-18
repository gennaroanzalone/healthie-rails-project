require 'rails_helper'

RSpec.describe Provider, type: :model do
  describe "validations" do
    it "requires a name" do
      provider = build(:provider, name: nil)
      expect(provider).not_to be_valid
    end

    it "requires a unique email (case-insensitive)" do
      create(:provider, email: "doc@example.com")
      dup = build(:provider, email: "DOC@example.com")
      expect(dup).not_to be_valid
    end

    it "rejects malformed emails" do
      expect(build(:provider, email: "not-an-email")).not_to be_valid
    end

    it "normalizes email to stripped lowercase so the unique index enforces case-insensitivity" do
      provider = create(:provider, email: "  Doc@Example.com  ")
      expect(provider.email).to eq("doc@example.com")
    end
  end

  describe "associations" do
    it "has many clients through memberships" do
      provider = create(:provider)
      client_a = create(:client)
      client_b = create(:client)
      create(:membership, provider: provider, client: client_a)
      create(:membership, provider: provider, client: client_b)

      expect(provider.clients).to contain_exactly(client_a, client_b)
    end
  end

  describe "#client_journal_entries" do
    it "returns entries across all of the provider's clients, oldest first" do
      provider = create(:provider)
      client_a = create(:client)
      client_b = create(:client)
      create(:membership, provider: provider, client: client_a)
      create(:membership, provider: provider, client: client_b)

      oldest = create(:journal_entry, client: client_a, created_at: 3.days.ago, body: "oldest")
      middle = create(:journal_entry, client: client_b, created_at: 2.days.ago, body: "middle")
      newest = create(:journal_entry, client: client_a, created_at: 1.day.ago,  body: "newest")

      expect(provider.client_journal_entries).to eq([ oldest, middle, newest ])
    end

    it "excludes journal entries from clients that don't belong to the provider" do
      provider     = create(:provider)
      own_client   = create(:client)
      other_client = create(:client)
      create(:membership, provider: provider, client: own_client)

      mine    = create(:journal_entry, client: own_client)
      _theirs = create(:journal_entry, client: other_client)

      expect(provider.client_journal_entries).to contain_exactly(mine)
    end

    it "returns nothing when the provider's clients have no entries" do
      provider = create(:provider)
      create(:membership, provider: provider, client: create(:client))

      expect(provider.client_journal_entries).to be_empty
    end
  end
end
