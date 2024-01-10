# frozen_string_literal: true

module InvoiceJob
  class Nightly < ApplicationJob
    Invoice.paid_v2.each do |invoice|
      if invoice.local_hcb_code.canonical_transactions.count == 2 || invoice.completed_deprecated? # payout + fee reimbursement
        invoice.mark_deposited!
      end
    end

  end
  
end
