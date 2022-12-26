# frozen_string_literal: true

class DropOutgoingTwilioMessages < ActiveRecord::Migration[6.1]
  def change
    drop_table :outgoing_twilio_messages
  end

end
