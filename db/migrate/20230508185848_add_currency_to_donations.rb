# frozen_string_literal: true

class AddCurrencyToDonations < ActiveRecord::Migration[7.0]
  def change
    add_column :donations, :currency, :integer, default: 0
  end

end
