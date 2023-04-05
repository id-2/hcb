# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V2::IndexContract, type: :model do
  let(:contract) { Api::V2::IndexContract.new.call }

  it "is successful" do
    expect(contract).to be_success
  end
end
