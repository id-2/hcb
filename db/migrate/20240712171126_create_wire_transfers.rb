class CreateWireTransfers < ActiveRecord::Migration[7.1]
  def change
    create_table :wire_transfers do |t|
      t.references :event, index: true, foreign_key: true
      t.references :creator, index: true, foreign_key: { to_table: :users }

      t.text :account_number_ciphertext
      t.integer :amount_cents
      t.string :currency_code
      t.datetime :approved_at
      t.string :bank_name
      t.string :bic_number
      t.text :payment_for
      t.text :recipient_name_ciphertext
      t.text :recipient_address_line1_ciphertext
      t.text :recipient_address_line2_ciphertext
      t.text :recipient_address_city_ciphertext
      t.text :recipient_address_postal_code_ciphertext
      t.text :recipient_address_country_code_ciphertext
      t.text :recipient_phone_ciphertext
      t.text :recipient_email_ciphertext
      t.text :recipient_legal_id_ciphertext
      t.text :recipient_legal_type_ciphertext
      t.text :recipient_local_bank_code_ciphertext
      t.text :recipient_local_account_number_ciphertext
      t.text :column_id

      t.timestamps
    end
  end
end
