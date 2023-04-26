# frozen_string_literal: true

require "rails_helper"

RSpec.describe LobCheckService::LobUrl::Generate, type: :model do
  let(:lob_check) { create(:lob_check) }

  let(:attrs) do
    {
      lob_check: lob_check,
    }
  end

  let(:service) { LobCheckService::LobUrl::Generate.new(attrs) }

  let(:url) { "http://lob.com/some/url" }
  let(:resp) { { "url" => url } }

  before do
    allow(service).to receive(:remote_lob_check).and_return(resp)
  end

  it "returns a url" do
    result = service.run

    expect(result).to eql(url)
  end
end
