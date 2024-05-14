class OrganizerPosition::Spending::ControlPolicy < ApplicationPolicy
  def new?
    user.admin? ||
    OrganizerPosition.find_by(user:, event: record.organizer_position.event).manager?
  end

  def destroy?
    user.admin? ||
    OrganizerPosition.find_by(user:, event: record.organizer_position.event).manager?
  end

end
