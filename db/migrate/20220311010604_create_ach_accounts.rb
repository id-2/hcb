# frozen_string_literal: true

class CreateAchAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :ach_accounts do |t|
      t.text :bank_name_ciphertext, null: false
      t.text :routing_number_ciphertext, null: false
      t.text :account_number_ciphertext, null: false

      t.timestamps
    end
  end

end
