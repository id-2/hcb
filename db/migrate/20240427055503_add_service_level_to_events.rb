class AddServiceLevelToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :service_level, :integer, default: 1
  end
end
