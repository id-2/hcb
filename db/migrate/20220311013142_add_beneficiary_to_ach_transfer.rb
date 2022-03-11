# frozen_string_literal: true

class AddBeneficiaryToAchTransfer < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    safety_assured do
      add_reference :ach_transfers, :beneficiary,
                    polymorphic: true,
                    index: { algorithm: :concurrently }
    end
  end

end
