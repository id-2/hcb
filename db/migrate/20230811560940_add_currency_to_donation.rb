# frozen_string_literal: true

class AddCurrencyToDonation < ActiveRecord::Migration[5.2]
  def change
    add_column :donations, :currency, :text, default: "USD"
  end

end
