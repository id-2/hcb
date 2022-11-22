# frozen_string_literal: true

class AddLegalNameToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :legal_name, :string
  end

end
