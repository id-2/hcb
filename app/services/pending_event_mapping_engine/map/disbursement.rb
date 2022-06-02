# frozen_string_literal: true

module PendingEventMappingEngine
  module Map
    class Disbursement
      def run
        unmapped.find_each(batch_size: 100) do |cpt|
          ::PendingEventMappingEngine::Map::Single::Disbursement.new(canonical_pending_transaction: cpt).run
        end
      end

      private

      def unmapped
        CanonicalPendingTransaction.unmapped.disbursement
      end

    end
  end
end
