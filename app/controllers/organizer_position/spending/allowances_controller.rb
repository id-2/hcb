class OrganizerPosition
  module Spending
    class AllowancesController < ApplicationController
      before_action :set_active_control

      def new
        @provisional_allowance = @active_control.organizer_position_spending_allowances.build

        authorize @spending_allowance
      end

      def create
        attributes = filtered_params
        attributes[:authorized_by_id] = current_user.id
        @allowance = @active_control.organizer_position_spending_allowances.build(attributes)

        authorize @allowance

        if @allowance.save
          flash[:success] = "Spending allowance created."
          redirect_to event_organizer_spending_control_path id: @allowance.organizer_position
        else
          render :new, status: :unprocessable_entity
        end
      end

      private

      def set_active_control
        @active_control = OrganizerPosition::Spending::Control.find(params[:control_id])
      end

      def filtered_params
        params.permit(:amount, :memo)
      end

    end
  end
end
