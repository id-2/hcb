class AddNotificationSettings < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :enabled_notifications, :integer,default: 0, null: false
    add_column :organizer_positions, :enabled_notifications, :integer,default: 0, null: false
  end
end
