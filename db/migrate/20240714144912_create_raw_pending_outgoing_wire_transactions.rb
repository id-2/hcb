class CreateRawPendingOutgoingWireTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :raw_pending_outgoing_wire_transactions do |t|
      t.integer :amount_cents
      t.date :date_posted
      t.string :state
      t.references :wire_transaction, null: false, foreign_key: true

      t.timestamps
    end
  end
end
