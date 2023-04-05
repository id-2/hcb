# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V2::OrganizationsContract, type: :model do
  let(:contract) { Api::V2::OrganizationsContract.new }

  it "is successful" do
    expect(contract).to be_success
  end
end
