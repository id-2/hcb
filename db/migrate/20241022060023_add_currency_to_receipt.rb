class AddCurrencyToReceipt < ActiveRecord::Migration[7.2]
  def change
    add_column :receipts, :extracted_total_amount_currency, :string, default: "USD"
  end
end
