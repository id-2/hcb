class AddCardGrantIdToStripeCards < ActiveRecord::Migration[7.2]
  def change
    add_column :stripe_cards, :card_grant_id, :integer
  end
end
