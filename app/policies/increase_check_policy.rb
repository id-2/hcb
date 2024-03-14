# frozen_string_literal: true

class IncreaseCheckPolicy < ApplicationPolicy
  only_admins_can :approve?, :reject?

  permit_admins_to def new?
    user_who_can_transfer?
  end

  permit_admins_to def create?
    user_who_can_transfer? && !record.event.outernet_guild?
  end

  private

  def admin_or_user
    user&.admin? || record.event.users.include?(user)
  end

  def user_who_can_transfer?
    EventPolicy.new(user, record.event).new_transfer?
  end

end
