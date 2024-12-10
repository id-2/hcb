class ChangeStripeTopupIdColumnType < ActiveRecord::Migration[7.2]
  def change
    safety_assured { change_column :stripe_service_fees, :stripe_topup_id, 'bigint USING CAST(stripe_topup_id AS bigint)' }
  end
end
