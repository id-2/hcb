# frozen_string_literal: true

module Api
  module V4
    class UserPolicy < ApplicationPolicy
      def show?
        has_scope?("read:user") && record == user
      end

    end
  end

end
