# frozen_string_literal: true

module Reimbursement
  class ExpensesController < ApplicationController
    def create
      @report = Reimbursement::Report.find(params[:report_id])
      @expense = @report.expenses.build(report: @report, amount_cents: 0)

      authorize @expense

      if @expense.save!

        respond_to do |format|
          format.turbo_stream { render turbo_stream: turbo_stream.append(:expenses, partial: "reimbursement/expenses/expense", locals: { expense: @expense, start_enabled: true, scroll_on_load: true }) }
          format.html         { redirect_to url_for(@report) + "#expense-#{@expense.id}", flash: { success: "Expense created." } }
        end
      else
        redirect_to @report, flash: { error: "Failed to create this expense." }
      end
    end

    def edit
      @expense = Reimbursement::Expense.find(params[:id])

      authorize @expense
    end

    def update
      @expense = Reimbursement::Expense.find(params[:id])

      authorize @expense

      @expense.update!(expense_params)


      respond_to do |format|
        format.turbo_stream {
          streams = [
            turbo_stream.replace(:total, partial: "reimbursement/reports/total", locals: { report: @expense.report }),
            turbo_stream.replace(@expense, partial: "reimbursement/expenses/expense", locals: { expense: @expense })
          ]
          render turbo_stream: streams
        }
        format.html { redirect_to @expense.report, flash: { success: "Expense updated." } }
      end
    end

    def approve
      @expense = Reimbursement::Expense.find(params[:expense_id])

      authorize @expense

      @expense.mark_approved!

      respond_to do |format|
        format.turbo_stream {
          streams = [
            turbo_stream.replace(:total, partial: "reimbursement/reports/total", locals: { report: @expense.report }),
            turbo_stream.replace(@expense, partial: "reimbursement/expenses/expense", locals: { expense: @expense })
          ]
          render turbo_stream: streams
        }
        format.html { redirect_to @expense.report, flash: { success: "Expense approved." } }
      end
    end

    def destroy

      @expense = Reimbursement::Expense.find(params[:id])

      authorize @expense

      if @expense.delete
        respond_to do |format|
          format.turbo_stream {
            streams = [
              turbo_stream.replace(:total, partial: "reimbursement/reports/total", locals: { report: @expense.report }),
              turbo_stream.remove(@expense)
            ]
            render turbo_stream: streams
          }
          format.html { redirect_to @expense.report, flash: { success: "Expense deleted!" } }
        end
      else
        redirect_to @expense.report, flash: { error: "Failed to delete this expense." }
      end
    end

    def unapprove
      @expense = Reimbursement::Expense.find(params[:expense_id])

      authorize @expense

      @expense.mark_pending!

      respond_to do |format|
        format.turbo_stream {
          streams = [
            turbo_stream.replace(:total, partial: "reimbursement/reports/total", locals: { report: @expense.report }),
            turbo_stream.replace(@expense, partial: "reimbursement/expenses/form", locals: { expense: @expense })
          ]
          render turbo_stream: streams
        }
        format.html { redirect_to @expense.report, flash: { success: "Expense unapproved." } }
      end
    end

    private

    def expense_params
      params.require(:reimbursement_expense).permit(:amount, :memo, :description)
    end

  end
end
