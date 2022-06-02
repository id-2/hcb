# frozen_string_literal: true

module PendingTransactionEngine
  module CanonicalPendingTransactionService
    module ImportSingle
      class Disbursement
        def initialize(raw_pending_disbursement_transaction:)
          @raw_pending_disbursement_transaction = raw_pending_disbursement_transaction
        end

        def run
          return existing_canonical_pending_transaction if existing_canonical_pending_transaction

          ActiveRecord::Base.transaction do
            attrs = {
              date: @raw_pending_disbursement_transaction.date,
              memo: @raw_pending_disbursement_transaction.memo,
              amount_cents: @raw_pending_disbursement_transaction.amount_cents,
              raw_pending_disbursement_transaction_id: @raw_pending_disbursement_transaction.id
            }
            ::CanonicalPendingTransaction.create!(attrs)
          end
        end

        private

        def existing_canonical_pending_transaction
          @existing_canonical_pending_transaction ||= ::CanonicalPendingTransaction.where(raw_pending_disbursement_transaction_id: @raw_pending_disbursement_transaction.id).first
        end

      end
    end
  end
end
