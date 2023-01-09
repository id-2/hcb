# frozen_string_literal: true

class AddEventToReimbursement < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_reference :reimbursements, :event, null: false, index: { algorithm: :concurrently }
  end

end
