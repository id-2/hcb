# frozen_string_literal: true

module DisbursementJob
  class Daily < ApplicationJob
    def perform
      Disbursement.scheduled_for_today.find_each(batch_size: 100) do |disbursement|

        # 1. Create the raw pending transactions
        rpidt = ::PendingTransactionEngine::RawPendingIncomingDisbursementTransactionService::Disbursement::ImportSingle.new(disbursement:).run
        rpodt = ::PendingTransactionEngine::RawPendingOutgoingDisbursementTransactionService::Disbursement::ImportSingle.new(disbursement:).run

        # 2. Canonize the newly added raw pending transactions
        i_cpt = ::PendingTransactionEngine::CanonicalPendingTransactionService::ImportSingle::IncomingDisbursement.new(raw_pending_incoming_disbursement_transaction: rpidt).run
        o_cpt = ::PendingTransactionEngine::CanonicalPendingTransactionService::ImportSingle::OutgoingDisbursement.new(raw_pending_outgoing_disbursement_transaction: rpodt).run

        # 3. Map to event
        ::PendingEventMappingEngine::Map::Single::IncomingDisbursement.new(canonical_pending_transaction: i_cpt).run
        ::PendingEventMappingEngine::Map::Single::OutgoingDisbursement.new(canonical_pending_transaction: o_cpt).run

        disbursement.mark_approved!(disbursement.fulfilled_by)
      end
    end

  end
end
