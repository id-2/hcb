# frozen_string_literal: true

class ReimbursementsController < ApplicationController
  include SetEvent
  before_action :set_event

  include Partners::Plaid::Shared::Client

  def index
    authorize @event, policy_class: ReimbursementPolicy
    @reimbursements = @event.reimbursements

    case params[:filter]
    when "approved"
      @reimbursements = @reimbursements.approved
    when "rejected"
      @reimbursements = @reimbursements.rejected
    else
      @reimbursements = @reimbursements.pending_approval
    end
  end

  def new
    authorize @event, policy_class: ReimbursementPolicy
    @reimbursement = Reimbursement.new
  end

  def create
    authorize @event, policy_class: ReimbursementPolicy
    reimbursement = Reimbursement.create!(params.require(:reimbursement).permit(:reimbursement_for, :amount_cents, :receipt).merge(event: @event, user: current_user))
    redirect_to new_event_reimbursement_path(@event), flash: { success: "Request submitted!" }
  end

end
