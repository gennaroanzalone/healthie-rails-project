require 'rails_helper'

RSpec.describe JournalEntry, type: :model do
  describe "validations" do
    it "requires a body" do
      expect(build(:journal_entry, body: nil)).not_to be_valid
    end

    it "belongs to a client" do
      expect(build(:journal_entry, client: nil)).not_to be_valid
    end
  end

  describe ".oldest_first" do
    it "orders entries oldest first" do
      client = create(:client)
      newer = create(:journal_entry, client: client, created_at: 1.hour.ago)
      older = create(:journal_entry, client: client, created_at: 1.week.ago)

      expect(JournalEntry.oldest_first).to eq([ older, newer ])
    end
  end
end
