class OrganizerPositions::Spending::ControlPolicy < ApplicationPolicy
  def index?
    true
  end

  def new?
    true
  end

  def destroy?
    true
  end

end
