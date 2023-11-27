# frozen_string_literal: true

class ProductPolicy < ApplicationPolicy
  def create?
    admin_or_user
  end
  
  def update?
    admin_or_user
  end
  
  def delete?
    admin_or_user
  end
  
  private
  
  def admin_or_user
    user&.admin? || record.event.users.include?(user)
  end

end
