# frozen_string_literal: true

class ReimbursementPolicy < ApplicationPolicy
  def index?
    record.users.include?(user)
  end

  def new?
    record.users.include?(user)
  end

  def create?
    record.users.include?(user)
  end

end
