# frozen_string_literal: true

# == Schema Information
#
# Table name: twilio_messages
#
#  id                 :bigint           not null, primary key
#  body               :text
#  direction          :integer          default("outgoing"), not null
#  from               :text
#  raw_data           :jsonb
#  to                 :text
#  twilio_account_sid :text
#  twilio_sid         :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  hcb_code_id        :bigint
#
# Indexes
#
#  index_twilio_messages_on_hcb_code_id  (hcb_code_id)
#
class TwilioMessage < ApplicationRecord
  validates_presence_of :to, :from, :twilio_sid, :twilio_account_sid, :raw_data

  enum direction: {
    outgoing: 0,
    incoming: 1,
  }

  belongs_to :hcb_code

  has_many_attached :files

  def twilio_log_url
    "https://www.twilio.com/console/sms/logs/#{twilio_account_sid}/#{twilio_sid}"
  end

end
