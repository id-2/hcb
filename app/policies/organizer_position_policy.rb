# frozen_string_literal: true

class OrganizerPositionPolicy < ApplicationPolicy
  def destroy?
    user.admin?
  end

  def set_index?
    record.user == user
  end

  def mark_visited?
    record.user == user
  end

  def update?
    return false if record.user.admin?
    return false if record.user == user

    return user.admin? || user.position(record.event).manager?
  end

end
