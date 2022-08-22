# frozen_string_literal: true

module PendingEventMappingEngine
  module Decline
    module Single
      class Invoice
        def initialize(canonical_pending_transaction:)
          @canonical_pending_transaction = canonical_pending_transaction
        end

        def run
          return unless @canonical_pending_transaction.unsettled?

          return unless invoice

          return unless invoice.manually_marked_as_paid?

          if @canonical_pending_transaction.settled?
            return Airbrake.notify("Invoice #{invoice.id} is manually marked as paid but is settled")
          end

          CanonicalPendingDeclinedMapping.create!(
            canonical_pending_transaction_id: @canonical_pending_transaction.id
          )
        end

        private

        def invoice
          @canonical_pending_transaction.local_hcb_code.invoice
        end

      end
    end
  end
end
