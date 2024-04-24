class CreateOrganizerPositionSpendingAuthorizations < ActiveRecord::Migration[7.0]
  def change
    create_table :organizer_position_spending_authorizations do |t|
      t.references :organizer_position, null: false, foreign_key: true, index: { name: "idx_org_pos_spend_allows_on_org_pos_id" }
      t.references :authorized_by, null: false, foreign_key: { to_table: :users }, index: { name: "idx_org_pos_spend_allows_on_authed_by_id" }
      t.integer :amount_cents, null: false
      t.text :memo

      t.timestamps
    end
  end
end

