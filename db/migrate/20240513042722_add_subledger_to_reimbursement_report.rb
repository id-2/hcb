class AddSubledgerToReimbursementReport < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_reference :reimbursement_reports, :subledger, null: true, index: { algorithm: :concurrently }
  end
end
