# frozen_string_literal: true

class RemoveAchAccountFromAchRecipients < ActiveRecord::Migration[6.0]
  def change
    safety_assured { remove_reference :ach_recipients, :ach_account, null: false, foreign_key: true }
  end

end
