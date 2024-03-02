# frozen_string_literal: true

module Reimbursement
  class ExpensePolicy < ApplicationPolicy
    def index?
      user&.admin?
    end

    def create?
      unlocked && (admin || team_member || creator)
    end

    def show?
      is_public || admin || team_member || creator
    end

    def edit?
      unlocked && (admin || team_member || creator)
    end

    def update?
      unlocked && (admin || team_member || creator)
    end

    def destroy?
      unlocked && (admin || team_member || creator)
    end

    def toggle_approved?
      admin || team_member
    end

    def user_made_expense?
      record&.report&.user == user
    end

    alias receiptable_upload?, user_made_purchase?

    private

    def admin
      user&.admin?
    end

    def team_member
      record.event.users.include?(user)
    end

    def creator
      record.report.user == user
    end

    def unlocked
      !record.report.locked?
    end

    def is_public
      record.event.is_public?
    end

  end
end
