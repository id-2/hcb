# frozen_string_literal: true

module Api
  module V4
    class StripeCardPolicy < ApplicationPolicy
      def show?
        (has_scope?("read:user:cards") && record.user == user) ||
          (has_scope?("read:org:cards") && record.event.include?(user))
      end

      def update?
        (has_scope?("write:user:cards") && record.user == user) ||
          (has_scope?("write:org:cards") && record.event.include?(user))
      end

    end
  end

end
