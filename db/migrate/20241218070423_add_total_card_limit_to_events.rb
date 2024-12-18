class AddTotalCardLimitToEvents < ActiveRecord::Migration[7.2]
  def change
    add_column :events, :total_card_limit, :integer
  end
end