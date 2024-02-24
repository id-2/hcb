# frozen_string_literal: true

module Reimbursement
  class ReportsController < ApplicationController
    before_action :set_event_user_and_event, except: [:create]

    # POST /reimbursement_reports
    def create
      @event = Event.friendly.find(report_params[:event_id])
      user = User.find_or_create_by!(email: report_params[:email])
      @report = @event.reimbursement_reports.build(report_params.merge(user:))

      authorize @report

      if @report.save!
        redirect_to event_reimbursements_path(@event), flash: { success: "Report successfully created." }
      else
        redirect_to event_reimbursements_path(@event), flash: { error: @report.errors.full_messages.to_sentence }
      end
    end

    def show
      @commentable = @report
      @comments = @commentable.comments
      @comment = Comment.new

      authorize @report
    end

    def edit
      authorize @report
    end

    def update
      @report.assign_attributes(update_reimbursement_report_params)
      authorize @report

      if @report.save
        flash[:success] = "Report successfully updated."
        redirect_to @report
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # The following routes handle state changes for the reports.

    def draft

      authorize @report

      if @report.mark_draft!
        flash[:success] = "Report marked as a draft, you can now make edits."
      else
        flash[:error] = @report.errors.full_messages.to_sentence
      end

      redirect_to @report
    end

    def submit
      authorize @report

      if @report.mark_submitted!
        flash[:success] = "Report submitted for review. To make further changes, mark it as a draft."
      else
        flash[:error] = @report.errors.full_messages.to_sentence
      end

      redirect_to @report
    end

    def request_reimbursement

      authorize @report

      if @report.mark_reimbursement_requested!
        flash[:success] = "Reimbursement requested; the HCB team will review the request promptly."
      else
        flash[:error] = @report.errors.full_messages.to_sentence
      end

      redirect_to @report
    end

    def admin_approve

      authorize @report

      if @report.mark_reimbursement_approved!
        flash[:success] = "Reimbursement has been approved; the team & report creator will be notified."
      else
        flash[:error] = @report.errors.full_messages.to_sentence
      end

      redirect_to @report
    end

    def reject

      authorize @report

      if @report.mark_rejected!
        flash[:success] = "Rejected & closed the report; no further changes can be made."
      else
        flash[:error] = @report.errors.full_messages.to_sentence
      end

      redirect_to @report
    end

    # this is a custom method for creating a comment
    # that also makes the report as a draft.
    # - @sampoder

    def request_changes

      authorize @report

      @report.mark_draft!

      @comment = @report.comments.build(params.require(:comment).permit(:content, :file, :admin_only, :action))
      @comment.user = current_user

      if @comment.save
        flash[:success] = "Changes requested; the creator will be notified."
      else
        flash[:error] = @report.errors.full_messages.to_sentence
      end

      redirect_to @report
    end

    private

    def set_event_user_and_event
      @report = Reimbursement::Report.find(params[:report_id])
      @event = @report.event
      @user = @report.user
    end

    def report_params
      report_params = params.require(:reimbursement_report).permit(:report_name, :maximum_amount, :event_id, :user_email, :other_email)
      report_params[:maximum_amount] = report_params[:maximum_amount].presence
      report_params[:email] = report_params[:user_email] == "other" ? report_params[:other_email] : report_params[:user_email]
      report_params.except(:user_email, :other_email)
    end

    def update_reimbursement_report_params
      reimbursement_report_params = params.require(:reimbursement_report).permit(:report_name, :maximum_amount)
      reimbursement_report_params[:maximum_amount] = reimbursement_report_params[:maximum_amount].presence
      reimbursement_report_params.delete(:maximum_amount) unless @current_user.admin? || @current_user != @report.user
      reimbursement_report_params
    end

  end
end
