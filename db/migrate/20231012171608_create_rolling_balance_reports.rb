# frozen_string_literal: true

class CreateRollingBalanceReports < ActiveRecord::Migration[7.0]
  def change
    create_table :rolling_balance_reports, if_not_exists: true do |t|
      t.references :creator, foreign_key: { to_table: :users }
      t.integer    :job_runtime_seconds
      t.string     :aasm_state

      t.timestamps
    end
  end

end
