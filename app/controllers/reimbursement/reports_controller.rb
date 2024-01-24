# frozen_string_literal: true

module Reimbursement
  class ReportsController < ApplicationController
    # POST /reimbursement_reports
    def create
      @event = Event.friendly.find(reimbursement_report_params[:event_id])
      @report = @event.reimbursement_reports.build(reimbursement_report_params.merge(user: current_user))
    
      authorize @report
    
      if @report.save
        redirect_to event_reimbursements_path(@event), flash: { success: "Report created." }
      else
        render :new, status: :unprocessable_entity
      end
    end
    
    def reimbursement_report_params
      reimbursement_report_params = params.require(:reimbursement_report).permit(:report_name, :maximum_amount, :event_id)
    end

  end
end
