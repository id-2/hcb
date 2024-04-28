class AddPersonalisationDesignToStripeCard < ActiveRecord::Migration[7.0]
  def change
    add_column :stripe_cards, :stripe_personalization_design_id, :text
  end
end
