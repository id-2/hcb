class RemovePlaintextTokensFromUserEmailUpdates < ActiveRecord::Migration[7.2]
  def change
    remove_column :user_email_updates, :authorization_token, :string
    remove_column :user_email_updates, :verification_token, :string
  end
end
