# frozen_string_literal: true

module Reimbursement
  class ExpensesController < ApplicationController
    before_action :set_expense, except: [:create]

    def create
      @report = Reimbursement::Report.find(params[:report_id])
      @expense = @report.expenses.build(report: @report, amount_cents: 0)

      authorize @expense

      if @expense.save!
        respond_to do |format|
          format.turbo_stream { render turbo_stream: new_expense_turbo_stream }
          format.html { redirect_to url_for(@report) + "#expense-#{@expense.id}" }
        end
      else
        redirect_to @report, flash: { error: @expense.errors.full_messages.to_sentence }
      end
    end

    def edit
      authorize @expense
    end

    def update
      authorize @expense

      @expense.update!(expense_params)

      respond_to do |format|
        format.turbo_stream { render turbo_stream: on_update_streams }
        format.html { redirect_to @expense.report, flash: { success: "Expense successfully updated." } }
      end
    end

    def toggle_approved
      authorize @expense

      if @expense.pending?
        @expense.mark_approved!
      else
        @expense.mark_pending!
      end

      respond_to do |format|
        format.turbo_stream { render turbo_stream: on_update_streams }
        format.html { redirect_to @expense.report }
      end
    end

    def destroy
      authorize @expense

      if @expense.delete
        respond_to do |format|
          format.turbo_stream { render turbo_stream: on_delete_streams }
          format.html { redirect_to @expense.report, flash: { success: "Expense successfully deleted." } }
        end
      else
        redirect_to @expense.report, flash: { error: @expense.errors.full_messages.to_sentence }
      end
    end

    private

    def expense_params
      params.require(:reimbursement_expense).permit(:amount, :memo, :description)
    end

    def set_expense
      @expense = Reimbursement::Expense.find(params[:expense_id] || params[:id])
    end

    def total_turbo_stream
      turbo_stream.replace(:total, partial: "reimbursement/reports/total", locals: { report: @expense.report })
    end

    def replace_expense_turbo_stream
      turbo_stream.replace(@expense, partial: "reimbursement/expenses/expense", locals: { expense: @expense })
    end

    def new_expense_turbo_stream
      turbo_stream.append(:expenses, partial: "reimbursement/expenses/expense", locals: { expense: @expense, new: true })
    end

    def delete_expense_turbo_stream
      turbo_stream.remove(@expense)
    end

    def on_update_streams
      [total_turbo_stream, replace_expense_turbo_stream]
    end

    def on_delete_streams
      [total_turbo_stream, turbo_stream.remove(@expense)]
    end

  end
end
