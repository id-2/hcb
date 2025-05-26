class AddCompactModeToOrganizerPositions < ActiveRecord::Migration[7.2]
  def change
    add_column :organizer_positions, :compact_mode, :boolean, default: false
  end
end
