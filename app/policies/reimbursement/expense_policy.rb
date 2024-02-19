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
      admin_or_user_unlocked && !record.event.demo_mode
    end

    def show?
      is_public || admin_or_user || creator
    end

    def edit?
      admin_or_user_unlocked || creator
    end

    def update?
      admin_or_user_unlocked || creator
    end

    def approve?
      admin_or_user
    end

    def unapprove?
      admin_or_user
    end

    private

    def admin_or_user
      user&.admin? || record.event.users.include?(user)
    end

    def admin_or_user_unlocked
      user&.admin? || (record.event.users.include?(user) && !record.report.locked?)
    end

    def creator
      record.report.user == user && !record.report.locked?
    end

    def is_public
      record.event.is_public?
    end

  end
end
