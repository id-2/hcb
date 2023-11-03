# frozen_string_literal: true

class DropRawPendingPartnerDonationTransactions < ActiveRecord::Migration[7.0]
  def up
    drop_table :raw_pending_partner_donation_transactions, force: :cascade
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

end
