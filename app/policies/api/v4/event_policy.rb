# frozen_string_literal: true

module Api
  module V4
    class EventPolicy < ApplicationPolicy
      def index?
        has_scope?("read:orgs")
      end

      def show?
        has_scope?("read:orgs") && record.users.include?(user)
      end

      def transactions?
        has_scope?("read:org:transactions") && record.users.include?(user)
      end

    end
  end

end
