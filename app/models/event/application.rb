# == Schema Information
#
# Table name: event_applications
#
#  id                                 :bigint           not null, primary key
#  accommodations                     :text
#  contact_option                     :integer          not null
#  event_address_country_code_iso3166 :string           not null
#  event_address_postal_code          :string           not null
#  event_description                  :text
#  event_name                         :string           not null
#  event_website                      :string
#  existing_user                      :boolean          not null
#  referrer                           :string
#  slack_username                     :string
#  transparent                        :boolean          not null
#  user_birthday                      :string           not null
#  user_email                         :string           not null
#  user_first_name                    :string           not null
#  user_last_name                     :string           not null
#  user_phone                         :string           not null
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#
class Event
  class Application < ApplicationRecord

    enum :contact_option, {
      email: 0,
      slack: 1,
    }

    def create_event!
      Event.create!(
        name: event_name,
        is_public: transparent,
        country: event_address_country_code_iso3166,
        postal_code: event_address_postal_code,
        description: event_description,
        website: event_website,
        sponsorship_fee: 0.07,
        organization_identifier: "bank_#{SecureRandom.hex}",
        point_of_contact_id: User.find_by(email: "bank@hackclub.com"),
        omit_stats: false,
        can_front_balance: true,
        demo_mode: true,
        partner_id: Partner.find_by!(slug: "bank")
      )
    end

    def create_airtable_record
      ApplicationsTable.create(
        'First Name': user_first_name,
        'Last Name': user_last_name,
        'Email Address': user_email,
        'Phone Number': user_phone_number,
        'Date of Birth': user_birthday,
        'Event Name': event_name,
        'Event Website': event_website,
        'Tell us about your event': event_description,
        'Zip Code': event_address_postal_code,
        'Event Country Code': event_address_country_code_iso3166,
        'Have you used HCB for any previous events?': current_user ? "Yes, I have used HCB before" : "No, first time!",
        'How did you hear about HCB?': referrer,
        'Transparent': transparent,
        'HCB account URL': "https://hcb.hackclub.com/#{event.slug}",
        'Contact Option': params[:contact_option],
        'Slack Username': params[:slack_username],
        Accommodations: params[:accommodations],
        'HCB ID': event.id
      )
    end
  end

end
