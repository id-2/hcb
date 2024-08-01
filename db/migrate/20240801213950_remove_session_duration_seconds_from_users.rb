class RemoveSessionDurationSecondsFromUsers < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      remove_column :users, :session_duration_seconds, :integer
    end
  end

end
