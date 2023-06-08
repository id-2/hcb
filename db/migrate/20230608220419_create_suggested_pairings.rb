class CreateSuggestedPairings < ActiveRecord::Migration[7.0]
  def change
    create_join_table :receipts, :hcb_codes, table_name: :suggested_pairings do |t|
      t.float :distance
      t.timestamps
    end
  end
end
