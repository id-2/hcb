# frozen_string_literal: true

module Api
  module V4
    class HcbCodePolicy < ApplicationPolicy
      def show?
        (has_scope?("read:user:cards") && user_made_purchase?) ||
          (has_scope?("read:org:transactions") && present_in_events?)
      end

      private

      def present_in_events?
        record.events.select { |e| e.try(:users).try(:include?, user) }.present?
      end

      def user_made_purchase?
        record.stripe_card? && record.stripe_cardholder&.user == user
      end

    end
  end

end
