# frozen_string_literal: true

class AddUniqueConstraintToUsersPhoneNumber < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!
  
  def change
    add_index :users, :phone_number, unique: true, algorithm: :concurrently
  end

end
