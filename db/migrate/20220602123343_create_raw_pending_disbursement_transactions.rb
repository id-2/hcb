# frozen_string_literal: true

class CreateRawPendingDisbursementTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :raw_pending_disbursement_transactions do |t|
      t.integer :amount_cents
      t.date :date_posted
      t.string :state
      t.string :disbursement_transaction_id

      t.timestamps
    end
  end

end
