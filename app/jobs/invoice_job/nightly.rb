# frozen_string_literal: true

module InvoiceJob
  class Nightly < ApplicationJob
    Invoice.in_transit.each do |invoice|
      if invoice.local_hcb_code.canonical_transactions.count == 2 # payout + fee reimbursement
        invoice.mark_deposited!
      end
    end
  end
end