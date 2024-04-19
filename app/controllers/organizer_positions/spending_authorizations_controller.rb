class OrganizerPositions::SpendingAuthorizationsController < ApplicationController
  before_action :set_organizer_position
  
  def index
    authorize @op, :foo?
    @message = "hi!"
  end

  def new
    @spending_authorization = @op.spending_authorizations.build

    authorize @op, :foo?
  end

  def create
    attributes = filtered_params
    attributes[:amount_cents] = (attributes[:amount_cents].to_f.round(2) * 100).to_i
    attributes[:organizer_position_id] = attributes.delete(:organizer_id)
    attributes[:authorized_by_id] = current_user.id
    @authorization = @op.spending_authorizations.build(attributes)

    authorize @op, :foo?

    if @authorization.save
      flash[:success] = "Spending authorization created."
      redirect_to event_organizer_spending_authorizations_path organizer_id: @authorization.organizer_position.user.slug
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
    params.permit(:organizer_id, :amount_cents, :memo)
  end
end
