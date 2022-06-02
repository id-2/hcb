# frozen_string_literal: true

module PendingTransactionEngine
  module RawPendingDisbursementTransactionService
    module Disbursement
      class ImportSingle
        def initialize(disbursement:)
          @disbursement = disbursement
        end

        def run
          source_rpst = rpst(source_attrs)
          canonize! source_rpst
          map! source_rpst

          recipient_rpst = rpst(recipient_attrs)
          canonize! recipient_rpst
          map! recipient_rpst

          [source_rpst, recipient_rpst]
        end

        private

        def canonize!(rpst)
          ::PendingTransactionEngine::CanonicalPendingTransactionService::ImportSingle::Disbursement.new(raw_pending_disbursement_transaction: rpst).run
        end

        def map!(rpst)
          cpt = CanonicalPendingTransaction.find_by(raw_pending_disbursement_transaction_id: rpst.id)
          ::PendingEventMappingEngine::Map::Single::Disbursement.new(canonical_pending_transaction: cpt).run
        end

        def rpst(attrs)
          ::RawPendingDisbursementTransaction.find_or_create_by(attrs)
        end

        def source_attrs
          @source_attrs ||= {
            disbursement_transaction_id: @disbursement.id,
            amount_cents: -@disbursement.amount,
            date_posted: @disbursement.fulfilled_at
          }
        end

        def recipient_attrs
          @recipient_attrs ||= {
            disbursement_transaction_id: @disbursement.id,
            amount_cents: @disbursement.amount,
            date_posted: @disbursement.fulfilled_at
          }
        end

      end
    end
  end
end
