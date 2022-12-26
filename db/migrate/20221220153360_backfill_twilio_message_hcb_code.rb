# frozen_string_literal: true

class BackfillTwilioMessageHcbCode < ActiveRecord::Migration[6.1]
  class OutgoingTwilioMessage < ApplicationRecord; end
  class TwilioMessage < ApplicationRecord; end

  def change
    OutgoingTwilioMessage.all.each do |otm|
      twilio_message = TwilioMessage.find otm.twilio_message_id
      twilio_message.hcb_code_id = otm.hcb_code_id
      twilio_message.save!
    end
  end

end
