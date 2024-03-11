class AddExtractedFeaturesToReceipts < ActiveRecord::Migration[7.0]
  def change
    add_column :receipts, :suggested_memo, :string
    add_column :receipts, :suggested_amount_cents_subtotal, :integer
    add_column :receipts, :suggested_amount_cents_total, :integer
    add_column :receipts, :suggested_date, :datetime
    add_column :receipts, :suggested_card_last4, :string
    add_column :receipts, :suggested_merchant_name, :string
    add_column :receipts, :suggested_merchant_url, :string
  end
end
