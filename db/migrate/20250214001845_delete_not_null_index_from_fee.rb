class DeleteNotNullIndexFromFee < ActiveRecord::Migration[7.2]
  def change
    remove_index :fees, name: :index_fees_on_canonical_event_mapping_id
  end
end
