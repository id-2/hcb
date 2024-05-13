class OrganizerPosition::Spending::ControlPolicy < ApplicationPolicy
  def new?
    user.admin?
  end

  def destroy?

    user.admin?
  end

end
