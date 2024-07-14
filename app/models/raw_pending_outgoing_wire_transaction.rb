class RawPendingOutgoingWireTransaction < ApplicationRecord
  belongs_to :wire_transaction, foreign_key: :wire_transaction_id
end

class RawPendingOutgoingAchTransaction < ApplicationRecord
  monetize :amount_cents
  belongs_to :ach_transfer, foreign_key: :ach_transaction_id
  has_one :canonical_pending_transaction

  def date
    date_posted
  end

  def memo
    "ACH TRANSFER #{raw_name}".strip.upcase
  end

  def likely_event_id
    @likely_event_id ||= ach_transfer.event.id
  end

  private

  def raw_name
    ach_transfer.recipient_name
  end

end
