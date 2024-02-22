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

    def show
      @report = Reimbursement::Report.find(params[:id])
      @event = @report.event
      @user = @report.user

      @commentable = @report
      @comments = @commentable.comments
      @comment = Comment.new

      authorize @report
    end

    def edit
      @report = Reimbursement::Report.find(params[:id])
      @event = @report.event
      @user = @report.user

      authorize @report
    end

    def submit
      @report = Reimbursement::Report.find(params[:report_id])
      @event = @report.event
      @user = @report.user

      authorize @report

      if @report.mark_submitted!
        flash[:success] = "Report submitted for review. To make changes, mark it as a draft."
      else
        flash[:error] = "Failed to submit report."
      end

      redirect_to @report
    end

    def request_reimbursement
      @report = Reimbursement::Report.find(params[:report_id])
      @event = @report.event
      @user = @report.user

      authorize @report

      if @report.mark_reimbursement_requested!
        flash[:success] = "Reimbursement requested, awaiting admin approval."
      else
        flash[:error] = "Failed to request reimbursement."
      end

      redirect_to @report
    end

    def admin_approve
      @report = Reimbursement::Report.find(params[:report_id])
      @event = @report.event
      @user = @report.user

      authorize @report

      if @report.mark_reimbursement_approved!
        flash[:success] = "Reimbursement approved."
      else
        flash[:error] = "Failed to approve reimbursement."
      end

      redirect_to @report
    end

    def reject
      @report = Reimbursement::Report.find(params[:report_id])
      @event = @report.event
      @user = @report.user

      authorize @report

      if @report.mark_rejected!
        flash[:success] = "Rejected and closed report."
      else
        flash[:error] = "Failed to reject report."
      end

      redirect_to @report
    end

    def draft
      @report = Reimbursement::Report.find(params[:report_id])
      @event = @report.event
      @user = @report.user

      authorize @report

      if @report.mark_draft!
        flash[:success] = "Report marked as a draft, you can now make edits."
      else
        flash[:error] = "Failed to submit report."
      end

      redirect_to @report
    end

    def request_changes
      @report = Reimbursement::Report.find(params[:report_id])

      authorize @report

      @report.mark_draft!

      @comment = @report.comments.build(params.require(:comment).permit(:content, :file, :admin_only, :action))
      @comment.user = current_user

      if @comment.save
        flash[:success] = "Changes requested."
      else
        flash[:error] = "Failed to request changes."
      end

      redirect_to @report
    end

    def update
      @report = Reimbursement::Report.find(params[:id])
      @report.assign_attributes(update_reimbursement_report_params)
      authorize @report

      if @report.save
        flash[:success] = "Report successfully updated."
        redirect_to @report
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def reimbursement_report_params
      reimbursement_report_params = params.require(:reimbursement_report).permit(:report_name, :maximum_amount, :event_id, :user_email, :other_email)
      reimbursement_report_params[:maximum_amount] = reimbursement_report_params[:maximum_amount].presence
      reimbursement_report_params
    end

    def update_reimbursement_report_params
      reimbursement_report_params = params.require(:reimbursement_report).permit(:report_name, :maximum_amount)
      reimbursement_report_params[:maximum_amount] = reimbursement_report_params[:maximum_amount].presence
      reimbursement_report_params.delete(:maximum_amount) unless @current_user.admin? || @current_user != @report.user
      reimbursement_report_params
    end

  end
end
