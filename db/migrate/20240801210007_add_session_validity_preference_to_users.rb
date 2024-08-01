class AddSessionValidityPreferenceToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :session_validity_preference_minutes, :integer, default: 60 * 6
  end

end
