# frozen_string_literal: true

class CreateAchRecipients < ActiveRecord::Migration[6.0]
  def change
    create_table :ach_recipients do |t|
      t.references :event, index: true, foreign_key: true
      t.string :recipient_name
      t.string :routing_number
      t.string :account_number
      t.string :bank_name
      t.string :recipient_tel

      t.timestamps
    end
  end

end
