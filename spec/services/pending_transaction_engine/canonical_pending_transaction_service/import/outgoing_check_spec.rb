# frozen_string_literal: true

require "rails_helper"

describe PendingTransactionEngine::CanonicalPendingTransactionService::Import::OutgoingCheck do

  context "when there is a pending outgoing check transaction ready for processing" do
    it "processes into a CanonicalPendingTransaction" do
      expect(RawPendingOutgoingCheckTransaction.count).to eq(0)

      raw_pending_outgoing_check_transaction = create(:raw_pending_outgoing_check_transaction,
                                                      date_posted: Date.current)

      expect do
        described_class.new.run
      end.to change { CanonicalPendingTransaction.count }.by(1)
    end
  end

  context "when there are previously processed raw pending outgoing check transactions" do
    let(:raw_pending_outgoing_check_transaction) { create(:raw_pending_outgoing_check_transaction) }

    before do
      _processed_outgoing_check_canonical_pending_transaction = create(:canonical_pending_transaction, raw_pending_outgoing_check_transaction:)
    end

    it "ignores it when processing" do
      expect do
        described_class.new.run
      end.to change { CanonicalPendingTransaction.count }.by(0)
    end

    context "when there are also ready to process raw pending outgoing check transactions" do
      it "processes into a CanonicalPendingTransaction" do
        new_check_transaction = create(:raw_pending_outgoing_check_transaction,
                                       date_posted: Date.current,
                                       amount_cents: 1000)

        expect(RawPendingOutgoingCheckTransaction.count).to eq(2)

        expect do
          described_class.new.run
        end.to change { CanonicalPendingTransaction.count }.by(1)

        pending_transaction = CanonicalPendingTransaction.last
        expect(pending_transaction.raw_pending_outgoing_check_transaction_id).to eq(new_check_transaction.id)
        expect(pending_transaction.amount_cents).to eq(new_check_transaction.amount_cents)
      end
    end
  end

end
