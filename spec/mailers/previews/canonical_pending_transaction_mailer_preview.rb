# frozen_string_literal: true

class CanonicalPendingTransactionMailerPreview < ActionMailer::Preview
  def notify_approved
    # @cpt = CanonicalPendingTransaction.stripe.last
    @cpt = CanonicalPendingTransaction.stripe.where("amount_cents < ?", -1_000_00).last

    CanonicalPendingTransactionMailer.with(
      canonical_pending_transaction_id: @cpt.id,
    ).notify_approved
  end
  
  def send_survey
    # @cpt = CanonicalPendingTransaction.stripe.last
    @cpt = CanonicalPendingTransaction.card_grant.where("amount_cents < ?", -1_000_00).last
  
    CanonicalPendingTransactionMailer.with(
      canonical_pending_transaction_id: @cpt.id,
    ).send_survey
  end

end
