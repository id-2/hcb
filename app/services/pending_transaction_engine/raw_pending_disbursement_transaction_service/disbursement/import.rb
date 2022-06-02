# frozen_string_literal: true

module PendingTransactionEngine
  module RawPendingDisbursementTransactionService
    module Disbursement
      class Import
        def initialize
        end

        def run
          pending_disbursements.each do |d|
            ::PendingTransactionEngine::RawPendingDisbursementTransactionService::Disbursement::ImportSingle.new(disbursement: d).run
          end
        end

        private

        def pending_disbursements
          @pending_disbursements ||= begin
            # Eventually this should probably become just disbursement.pending or something
            ::Disbursement.all.where.not(fulfilled_at: nil).select { |disbursement| RawPendingDisbursementTransaction.where(disbursement_transaction_id: disbursement.id).size < 2 }
          end
        end

      end
    end
  end
end
