# frozen_string_literal: true

module Api
  module V4
    class UsersController < ApplicationController
      before_action(only: [:show]) { require_scope! "read:user" }

      def show
        @user = authorize current_user
      end

    end
  end
end
