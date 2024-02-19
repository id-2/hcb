class AddExtractedFeaturesToReceipts < ActiveRecord::Migration[7.0]
  def change
    change_table :receipts do |t|
      t.string :suggested_memo
      t.integer :suggested_amount_cents_subtotal
      t.integer :suggested_amount_cents_total
      t.datetime :suggested_date
      t.string :suggested_card_last4
      t.string :suggested_merchant_name
      t.string :suggested_merchant_url
    end
  end
end
