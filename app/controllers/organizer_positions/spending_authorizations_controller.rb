class OrganizerPositions::SpendingAuthorizationsController < ApplicationController
  before_action :set_organizer_position
  
  def index
    authorize @op, :foo?
    @message = "hi!"
  end

  def new
    authorize @op, :foo?

    @spending_limit = @op.spending_authorizations.build
  end

  def create
    authorize @op, :foo?

    @spending_limit = @op.spending_authorizations.build(spending_limit_params)
    if @spending_limit.save
      redirect_to @op, notice: 'Spending limit was successfully created.'
    else
      render :new
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

  def spending_limit_params
    params.require(:spending_limit).permit(:amount_cents, :memo)
  end
end
