class CreateAnnouncementsUsersJoinTable < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!
  
  def change
    create_join_table :announcements, :users
    add_index :announcements_users, [:announcement_id, :user_id], unique: true, algorithm: :concurrently
  end
end
