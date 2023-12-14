# frozen_string_literal: true

module Api
  module V4
    class OrganizerPositionInvitePolicy < ApplicationPolicy
      def show?
        has_scope?("read:user:invitations") && record.user == user
      end

      def accept?
        has_scope?("write:user:invitations") && record.user == user
      end

      def reject?
        has_scope?("write:user:invitations") && record.user == user
      end

    end
  end

end
