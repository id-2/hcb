class AddMfaFieldsToUserSession < ActiveRecord::Migration[7.1]
  def change
    add_column :user_sessions, :aasm_state, :string
    add_column :user_sessions, :permissions, :integer, default: 0, null: false
  end
end
