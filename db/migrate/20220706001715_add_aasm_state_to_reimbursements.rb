# frozen_string_literal: true

class AddAasmStateToReimbursements < ActiveRecord::Migration[6.1]
  def change
    add_column :reimbursements, :aasm_state, :string
  end

end
