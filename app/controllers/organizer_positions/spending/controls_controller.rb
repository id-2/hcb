class OrganizerPositions::Spending::ControlsController < ApplicationController
  before_action :set_organizer_position

  def new
    skip_authorization

    attributes = filtered_params
    attributes[:active] = true
    attributes[:started_at] = Time.current

    @control = @op.spending_controls.create(attributes)

    if @control.save
      @op.spending_controls
         .where(active: true)
         .where.not(id: @control.id)
         .update_all(active: false)

      flash[:success] = "Spending control successfully created!"
      redirect_to event_organizer_allowances_path organizer_id: @op.user.slug
    else
      # render :new, status: :unprocessable_entity
    end
  end

  def destroy
    skip_authorization

    if @op.active_spending_control.organizer_position_spending_allowances.count == 0
      @op.active_spending_control.ended_at = Time.current
      @op.active_spending_control.destroy
    end

    @op.spending_controls.each { |c| c.update(active: false) }

    flash[:success] = "Spending controls disabled for #{@op.user.name}!"
    redirect_to event_organizer_allowances_path organizer_id: @op.user.slug
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
    params.permit(:organizer_position_id)
  end

end
