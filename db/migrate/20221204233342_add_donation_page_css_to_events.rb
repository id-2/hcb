# frozen_string_literal: true

class AddDonationPageCssToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :donation_page_css, :text
  end
  
end
