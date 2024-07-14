class CreateWireTransfers < ActiveRecord::Migration[7.1]
  def change
    create_table :wire_transfers do |t|
      t.references :event, index: true, foreign_key: true
      t.references :creator, index: true, foreign_key: { to_table: :users }
      t.references :payment_recipient

      t.text :account_number_ciphertext
      t.integer :amount_cents
      t.string :currency_code
      t.datetime :approved_at
      t.string :bank_name
      t.string :bic_number
      t.text :payment_for
      t.text :column_id

      t.timestamps
    end
  end
end
