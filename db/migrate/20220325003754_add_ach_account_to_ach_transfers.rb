# frozen_string_literal: true

class AddAchAccountToAchTransfers < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_reference :ach_transfers, :ach_account, null: true,
                                                index: { algorithm: :concurrently }
  end

end
