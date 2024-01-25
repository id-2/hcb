# frozen_string_literal: true

module Reimbursement
  class ExpensesController < ApplicationController
    def create
      @report = Reimbursement::Report.find(params[:report_id])
      @expense = @report.expenses.build(report: @report, amount_cents: 0)

      authorize @expense

      if @expense.save!
        redirect_to url_for(@report) + "#expense-#{@expense.id}", flash: { success: "Expense created." }
      else
        redirect_to @report, flash: { error: "Failed to create this expense." }
      end
    end
  end
end
