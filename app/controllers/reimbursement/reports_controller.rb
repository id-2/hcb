# frozen_string_literal: true

module Reimbursement
  class ReportsController < ApplicationController
    # POST /reimbursement_reports
    def create
      @event = Event.friendly.find(reimbursement_report_params[:event_id])
      @report = @event.reimbursement_reports.build(reimbursement_report_params.except(:user_email, :other_email).merge(
                                                     user: User.find_or_create_by!(
                                                       email: if reimbursement_report_params[:user_email] == "other"
                                                                reimbursement_report_params[:other_email]
                                                              else
                                                                reimbursement_report_params[:user_email]
                                                              end
                                                     )
                                                   ))

      authorize @report

      if @report.save!
        redirect_to event_reimbursements_path(@event), flash: { success: "Report created." }
      else
        redirect_to event_reimbursements_path(@event), flash: { error: "Failed to create this report." }
      end
    end

    def reimbursement_report_params
      reimbursement_report_params = params.require(:reimbursement_report).permit(:report_name, :maximum_amount, :event_id, :user_email, :other_email)
      reimbursement_report_params[:maximum_amount] = reimbursement_report_params[:maximum_amount].presence
      reimbursement_report_params
    end

  end
end
