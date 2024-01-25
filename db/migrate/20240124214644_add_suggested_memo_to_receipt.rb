class AddSuggestedMemoToReceipt < ActiveRecord::Migration[7.0]
  def change
    add_column :receipts, :suggested_memo, :string
  end
end
