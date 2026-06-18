require 'rails_helper'

RSpec.describe Membership, type: :model do
  describe "plan enum" do
    it "exposes basic and premium" do
      expect(Membership.plans.keys).to contain_exactly("basic", "premium")
    end

    it "rejects an unknown plan" do
      expect { build(:membership, plan: "enterprise") }
        .to raise_error(ArgumentError)
    end
  end

  describe "validations" do
    it "requires a plan" do
      expect(build(:membership, plan: nil)).not_to be_valid
    end

    it "forbids duplicate provider/client pairs" do
      provider = create(:provider)
      client   = create(:client)
      create(:membership, provider: provider, client: client)

      dup = build(:membership, provider: provider, client: client)
      expect(dup).not_to be_valid
    end

    it "allows the same client with different providers" do
      client = create(:client)
      create(:membership, client: client, provider: create(:provider))
      expect(build(:membership, client: client, provider: create(:provider))).to be_valid
    end
  end
end
