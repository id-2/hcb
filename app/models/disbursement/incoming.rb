class Disbursement
  class Incoming
    def initialize(disbursement)
      @disbursement = disbursement
    end

    def hcb_code
      "HCB-#{TransactionGroupingEngine::Calculate::HcbCode::INCOMING_DISBURSEMENT_CODE}-#{@disbursement.id}"
    end

    def local_hcb_code
      @local_hcb_code ||= HcbCode.find_or_create_by(hcb_code:)
    end

    def canonical_pending_transactions
      @canonical_pending_transactions ||= ::CanonicalPendingTransaction.where(hcb_code:)
    end

  end
end
