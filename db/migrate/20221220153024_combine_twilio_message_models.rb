# frozen_string_literal: true

class CombineTwilioMessageModels < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_column :twilio_messages, :direction, :integer, null: false, default: 0
    add_reference :twilio_messages, :hcb_code, null: true, index: { algorithm: :concurrently }

  end

end
