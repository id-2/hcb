class AddPublishToggleToDonationTier < ActiveRecord::Migration[7.2]
  def change
    add_column :donation_tiers, :published, :boolean, default: false, null: false

    # Set all existing donation tiers to published
    Donation::Tier.update_all(published: true)
  end
end
