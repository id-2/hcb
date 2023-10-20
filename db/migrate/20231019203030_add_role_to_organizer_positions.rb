# frozen_string_literal: true

class AddRoleToOrganizerPositions < ActiveRecord::Migration[7.0]
  def change
    add_column :organizer_positions, :role, :integer, null: false, default: 1
  end

end
