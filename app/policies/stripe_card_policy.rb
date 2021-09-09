# frozen_string_literal: true

class StripeCardPolicy < ApplicationPolicy
  def index?
    user&.admin?
  end

  def shipping?
    is_admin_or_card_owner_or_event_member?
  end

  def freeze?
    is_admin_or_card_owner_or_event_member?
  end

  def defrost?
    is_admin_or_card_owner_or_event_member?
  end

  def spending_limit?
    is_admin_or_card_owner_or_event_member?
  end

  def set_spending_limit?
    is_admin_or_card_owner_or_event_member?
  end

  def show?
    user&.admin? || record&.event&.users&.include?(user)
  end

  private
  
  def is_admin_or_card_owner_or_event_member?
    user&.admin? || record&.event&.users&.include?(user) || record&.user == user
  end
end
