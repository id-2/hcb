# frozen_string_literal: true

class CanonicalTransactionPolicy < ApplicationPolicy
  only_admins_can :waive_fee?, :unwaive_fee?, :mark_bank_fee?

  permit_admins_to def show?
    user_is_organizer?
  end

  permit_admins_to def edit?
    user_is_organizer?
  end

  permit_admins_to def set_custom_memo?
    user_is_organizer?
  end

  permit_admins_to def export?
    user_is_organizer?
  end

  private

  def user_is_organizer?
    record&.event&.users&.include?(user)
  end

end
