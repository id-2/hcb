class OrganizerPosition
  module Spending
    class ControlPolicy < ApplicationPolicy
      def new?
        record.active && (
          user.admin? || (
            OrganizerPosition.find_by(user:, event: record.organizer_position.event).manager? &&
            user != record.organizer_position.user
          )
        )
      end

      def destroy?
        user.admin? ||
          OrganizerPosition.find_by(user:, event: record.organizer_position.event).manager?
      end

      private

    end
  end

end
