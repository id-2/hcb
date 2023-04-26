# frozen_string_literal: true

class RefundSentLobCheckJob < ApplicationJob
  queue_as :default

  def perform(lob_check)
    return if lob_check.deposited? || lob_check.pending_void? || lob_check.voided?

    LobCheckMailer.with(lob_check: lob_check).undeposited.deliver_later
    # LobCheckMailer.with(check: check).undeposited_organizers.deliver_later
    lob_check.void!
  end

end
