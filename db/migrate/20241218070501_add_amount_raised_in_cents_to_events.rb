class AddAmountRaisedInCentsToEvents < ActiveRecord::Migration[7.2]
  def change
    add_column :events, :amount_raised_in_cents, :integer, default: 0
  end
end