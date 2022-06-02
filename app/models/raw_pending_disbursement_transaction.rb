# frozen_string_literal: true

class RawPendingDisbursementTransaction < ApplicationRecord
  monetize :amount_cents

  def date
    date_posted
  end

  def memo
    "DISBURSEMENT".strip.upcase
  end

  def likely_event_id
    @likely_event_id ||= if amount_cents.positive?
                           disbursement.destination_event.id
                         else
                           disbursement.source_event.id
                         end
  end

  def disbursement
    @disbursement ||= ::Disbursement.find_by(id: disbursement_transaction_id)
  end

end
