class OrganizerPosition
  module Spending
    class ControlPolicy < ApplicationPolicy

      def index?
        user.admin? || manager? || user == record.organizer_position.user
      end

      def new?
          user.admin? || (manager? && user != record.organizer_position.user)
      end

      def destroy?
        user.admin? || manager?
      end

      private

      def manager?
        # Whether the current user is a manager, not the target of the control
        OrganizerPosition.find_by(user:, event: record.organizer_position.event).manager?
      end

    end
  end

end
