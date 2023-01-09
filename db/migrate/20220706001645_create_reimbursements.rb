# frozen_string_literal: true

class CreateReimbursements < ActiveRecord::Migration[6.1]
  def change
    create_table :reimbursements do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :amount_cents

      t.timestamps
    end
  end

end
