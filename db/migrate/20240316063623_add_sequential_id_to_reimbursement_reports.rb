class AddSequentialIdToReimbursementReports < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      add_column :reimbursement_expenses, :sequential_id, :integer
      
      execute <<~SQL
        UPDATE reimbursement_expenses
        SET sequential_id = old_reimbursement_expenses.next_sequential_id
        FROM (
          SELECT id, ROW_NUMBER()
          OVER(
            PARTITION BY reimbursement_report_id
            ORDER BY id
          ) AS next_sequential_id
          FROM reimbursement_expenses
        ) old_reimbursement_expenses
        WHERE reimbursement_expenses.id = old_reimbursement_expenses.id
      SQL
      
      change_column :reimbursement_expenses, :sequential_id, :integer, null: false
      add_index :reimbursement_expenses, [:sequential_id, :reimbursement_report_id], unique: true, name: "index_expenses_on_sequential_id_and_report_id"
    end
  end
end
