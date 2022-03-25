# frozen_string_literal: true

class AddBeneficiaryToAchAccount < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    safety_assured do
      add_reference :ach_accounts, :beneficiary,
                    polymorphic: true,
                    index: { algorithm: :concurrently }
    end
  end

end
