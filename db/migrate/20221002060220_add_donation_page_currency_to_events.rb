# frozen_string_literal: true

class AddDonationPageCurrencyToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :donation_page_currency, :text, default: "USD"
  end

end
