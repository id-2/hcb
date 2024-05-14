class OrganizerPosition::Spending::AllowancePolicy < ApplicationPolicy
  def index?
    # Record is an OrganizerPosition
    user.admin? ||
    OrganizerPosition.find_by(user:, event: record.event)&.manager? ||
    user == record.user
  end

  def new?
    true
  end

  def create?
    user.admin? ||
      OrganizerPosition.find_by(user:, event: record.event)&.manager?
  end

end
