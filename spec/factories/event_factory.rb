# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    name { Faker::Name.unique.name }
    sponsorship_fee { 0 }
    organization_identifier { SecureRandom.hex(30) }
    point_of_contact_id { create(:user, :make_admin).id }

    trait :demo_mode do
      demo_mode { true }
    end
  end
end
