class OrganizerPositions::Spending::ControlsController < ApplicationController
  before_action :set_organizer_position

  def create
    skip_authorization

    attributes = filtered_params
    attributes[:active] = true
    attributes[:started_at] = Time.current

    @control = @op.spending_controls.create(filtered_params)

    if @control.save
      @op.spending_controls
        .where(active: true)
        .where.not(id: @control.id)
        .update_all(active: false)

      flash[:success] = "Spending control successfully created!"
      redirect_to event_organizer_authorizations_path organizer_id: @op.user.slug
    else
      # render :new, status: :unprocessable_entity
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
