# frozen_string_literal: true

module Api
  module V4
    class ApplicationController < ActionController::API
      class MissingScopeError < StandardError; end

      include ActionController::HttpAuthentication::Token::ControllerMethods
      include Pundit::Authorization

      after_action :verify_authorized

      before_action :authenticate!

      rescue_from Pundit::NotAuthorizedError do |e|
        render json: { error: "not_authorized", description: "You may be missing a scope, or this user may not have access to this resource." }, status: :forbidden
      end

      rescue_from ActiveRecord::RecordNotFound do |e|
        render json: { error: "resource_not_found" }, status: :not_found
      end

      rescue_from ActiveRecord::RecordInvalid do |e|
        render json: { error: "invalid_operation", messages: e.record.errors.full_messages }, status: :bad_request
      end

      rescue_from MissingScopeError do |e|
        render json: { error: "missing_scope", description: e }, status: :forbidden
      end

      unless Rails.env.development?
        rescue_from StandardError do |e|
          notify_airbrake(e)
          render json: { error: "internal_server_error", description: "Something went wrong. Sorry about that!" }, status: :internal_server_error
        end
      end

      def not_found
        skip_authorization
        render json: { error: "not_found" }, status: :not_found
      end

      private

      def authenticate!
        @current_token = authenticate_with_http_token { |t, _options| ApiToken.find_by(token: t) }
        unless @current_token&.accessible?
          return render json: { error: "invalid_auth" }, status: :unauthorized
        end

        @current_user = current_token&.user
      end

      def require_scope!(*scopes)
        unless @current_token.acceptable?(scopes)
          raise MissingScopeError.new("One of the following scopes are required: #{scopes.join(", ")}")
        end
      end

      attr_reader :current_token, :current_user

      def pundit_user
        @current_token
      end

      def authorize(record, query = nil)
        super([:api, :v4, record], query)
      end

    end
  end
end
