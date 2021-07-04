# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserService::Create, type: :model do
  fixtures  "events"
  
  let(:event) { events(:event1) }

  let(:email) { "test_user@hackclub.com" }
  let(:full_name) { "John Doe" }
  let(:phone_number) { "8556254225" }
  
  let(:attrs) do
    {
      email: email,
      full_name: full_name,
      phone_number: phone_number,
      event_id: event.id,
    }
  end

  let(:service) { UserService::Create.new(attrs) }

  let(:remote_auth_token) { "abcd" }
  let(:remote_user_id) { 1234 }
  let(:remote_email) { email }
  let(:remote_admin_at) { nil }

  let(:exchange_login_code_resp) do
    {
      auth_token: auth_token
    }
  end

  let(:get_user_access_token) do
    {
      auth_token: remote_auth_token
    }
  end

  let(:get_user_resp) do
    {
      id: remote_user_id,
      email: remote_email,
      admin_at: remote_admin_at
    }
  end

  before do
    allow(service).to receive(:get_user_access_token).and_return(get_user_access_token)
    allow(service).to receive(:get_user_resp).and_return(get_user_resp)
  end

  it "returns the user" do
    user = service.run

    expect(user).to be_a User
  end

  it "should set api_id" do
    user = service.run

    expect(user.api_id).to eql(remote_user_id)
  end

  it "should set api_access_token" do
    user = service.run

    expect(user.api_access_token).to eql(remote_auth_token)
  end

  it "should set admin_at" do
    user = service.run

    expect(user.admin_at).to eql(remote_admin_at)
  end

  it "should set full_name" do
    user = service.run

    expect(user.full_name).to eql(full_name)
  end

  it "should set phone_number" do
    user = service.run

    expect(user.phone_number).to eql(phone_number)
  end

  context "when user already exists" do
    fixtures  "users"

    before do
      existing_user = users(:user1)
      existing_user.email = email
      existing_user.save!
    end

    it "raises an error" do
      expect do
        service.run
      end.to raise_error(ArgumentError)
    end
  end

  it "should create an OrganizerPosition" do
    user = service.run

    position = OrganizerPosition.find_by(user_id: user.id)
    expect(position).not_to be_nil
  end
end
