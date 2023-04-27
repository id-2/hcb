# frozen_string_literal: true

# == Schema Information
#
# Table name: raw_pending_outgoing_check_transactions
#
#  id                   :bigint           not null, primary key
#  amount_cents         :integer
#  date_posted          :date
#  state                :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  check_transaction_id :string
#
class RawPendingOutgoingCheckTransaction < ApplicationRecord
  monetize :amount_cents

  def date
    date_posted
  end

  def memo
    "CHECK TO #{raw_name} #{raw_memo}".strip.upcase
  end

  def check_number
    lob_check.check_number || "-----"
  end

  def likely_event_id
    @likely_event_id ||= lob_check.event.id
  end

  def lob_check
    @lob_check ||= ::LobCheck.find_by(id: check_transaction_id)
  end

  private

  def raw_memo
    lob_check.memo
  end

  def raw_name
    lob_check.lob_address.name
  end

end
