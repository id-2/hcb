class AddFulfilledByToAchTransfer < ActiveRecord::Migration[6.1]
  def change
    add_column :ach_transfers, :fulfilled_by_id, :bigint
  end
end
