# frozen_string_literal: true

class CreateAchRecipients < ActiveRecord::Migration[6.0]
  def change
    create_table :ach_recipients do |t|
      t.string :first_name
      t.string :last_name
      t.string :phone_number
      t.references :ach_account, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true

      t.timestamps
    end
  end

end
