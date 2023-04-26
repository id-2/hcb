# frozen_string_literal: true

require "rails_helper"

RSpec.describe LobCheck, type: :model do
  it "is valid" do
    lob_check = create(:lob_check)
    expect(lob_check).to be_valid
  end

  describe "#send_date" do
    it "must be at least 12 hours in the future" do
      lob_check = build(:lob_check, send_date: Time.now.utc + 1.hour)
      expect(lob_check).to_not be_valid
    end
  end
end
