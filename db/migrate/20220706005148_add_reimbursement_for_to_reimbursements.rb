class AddReimbursementForToReimbursements < ActiveRecord::Migration[6.1]
  def change
    add_column :reimbursements, :reimbursement_for, :text
  end
end
