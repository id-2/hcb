# frozen_string_literal: true

class DropPartnerDonationsPartneredSignupsPartners < ActiveRecord::Migration[7.0]
  def up
    drop_table :partner_donations, force: :cascade
    drop_table :partnered_signups, force: :cascade
    drop_table :partners, force: :cascade
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

end
