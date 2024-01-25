# frozen_string_literal: true

module Reimbursement
  class ExpensePolicy < ApplicationPolicy
    def index?
      user&.admin?
    end

    def new?
      is_public || admin_or_user
    end

    def create?
      admin_or_user && !record.event.demo_mode
    end

    def show?
      is_public || admin_or_user
    end

    def edit?
      admin_or_user
    end

    def update?
      admin_or_user
    end

    private

    def admin_or_user
      user&.admin? || record.event.users.include?(user)
    end

    def is_public
      record.event.is_public?
    end

  end
end
