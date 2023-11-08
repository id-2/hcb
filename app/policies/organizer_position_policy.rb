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
    return false if user.nil?
    return false if !Flipper.enabled?(:user_permissions, record.event)
    return false if record.user.admin?  # an admin's role can't be changed
    return false if record.user == user # a user can't change their own role

    return user.admin? || user.position(record.event).manager?
  end

end
