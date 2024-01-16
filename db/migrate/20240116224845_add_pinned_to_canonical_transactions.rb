class AddPinnedToCanonicalTransactions < ActiveRecord::Migration[7.0]
  def change
    add_column :canonical_transactions, :pinned, :boolean, default: false
  end
end
