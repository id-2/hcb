# frozen_string_literal: true

class RemovePartnerFields < ActiveRecord::Migration[7.0]
  def change
    safety_assured { remove_column :canonical_pending_transactions, :raw_pending_partner_donation_transaction_id }
    safety_assured { remove_column :login_tokens, :partner_id }
    safety_assured { remove_column :events, :partner_id }
  end

end
