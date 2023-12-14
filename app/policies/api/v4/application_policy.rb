# frozen_string_literal: true

module Api
  module V4
    class ApplicationPolicy
      attr_reader :token, :record

      def initialize(token, record)
        @token = token
        @record = record
      end

      def user
        @token.user
      end

      def has_scope?(*scopes)
        token.acceptable?(scopes)
      end

    end
  end
end
