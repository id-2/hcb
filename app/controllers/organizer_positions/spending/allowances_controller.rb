class OrganizerPositions::Spending::AllowancesController < ApplicationController
  before_action :set_organizer_position

  def index
    skip_authorization

    # @allowances_total = @allowances&.sum(:amount_cents) || 0
    # @transactions_total = @op.stripe_cards.where(event: @op.event).sum(&:total_spent)
    # @allowance_balance = @allowances_total - @transactions_total
  end

  def new
    @spending_allowance = @op.active_spending_control.organizer_position_spending_allowances.build

    authorize @op, :foo?
  end

  def create
    attributes = filtered_params
    attributes[:amount_cents] = (attributes[:amount_cents].to_f.round(2) * 100).to_i
    attributes[:authorized_by_id] = current_user.id
    @allowance = @op.active_spending_control.organizer_position_spending_allowances.build(attributes)

    authorize @op, :foo?

    if @allowance.save
      flash[:success] = "Spending allowance created."
      redirect_to event_organizer_allowances_path organizer_id: @allowance.organizer_position.user.slug
    else
      #      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_organizer_position
    @event = Event.friendly.find(params[:event_id])
    begin
      @user = User.friendly.find(params[:organizer_id])
      @op = OrganizerPosition.find_by!(event: @event, user: @user)
    rescue ActiveRecord::RecordNotFound
      @op = OrganizerPosition.find_by!(event: @event, id: params[:organizer_id])
    end
  end

  def filtered_params
    params.permit(:amount_cents, :memo)
  end

end
