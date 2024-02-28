# frozen_string_literal: true

module Reimbursement
  class ExpensePolicy < ApplicationPolicy
    def index?
      user&.admin?
    end

    def create?
      (admin || team_member || creator) && unlocked
    end

    def show?
      is_public || admin || team_member || creator
    end

    def edit?
      (admin || team_member || creator) && unlocked
    end

    def update?
      (admin || team_member || creator) && unlocked
    end

    def destroy?
      (admin || team_member || creator) && unlocked
    end

    def toggle_approved?
      admin || team_member
    end

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
