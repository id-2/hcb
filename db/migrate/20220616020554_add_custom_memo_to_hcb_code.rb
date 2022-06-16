# frozen_string_literal: true

class AddCustomMemoToHcbCode < ActiveRecord::Migration[6.1]
  def change
    add_column :hcb_codes, :custom_memo, :text
  end

end
