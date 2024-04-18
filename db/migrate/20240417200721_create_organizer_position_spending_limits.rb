class CreateOrganizerPositionSpendingLimits < ActiveRecord::Migration[7.0]
  def change
    create_table :organizer_position_spending_limits do |t|
      t.references :organizer_position, null: false, foreign_key: true
      t.references :authorized_by, null: false, foreign_key: { to_table: :users }
      t.integer :amount_cents, null: false
      t.text :memo

      t.timestamps
    end
  end
end
