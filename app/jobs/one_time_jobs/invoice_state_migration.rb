# frozen_string_literal: true

module OneTimeJobs
  class InvoiceStateMigration < ApplicationJob
    def perform
      Invoice.find_each(batch_size: 100) do |invoice|
        if invoice.archived?
          invoice.mark_archived!
        end
        if invoice.deposited?
          invoice.mark_deposited!
        end
      end
    end

  end
end
