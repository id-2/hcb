# frozen_string_literal: true

# Emoji helpers for policies
module EmojiPolicies
  extend ActiveSupport::Concern

  included do
    # Default accessors for use within policies. These may be overridden by
    # subclasses (e.g. actual policies classes) to provide a more
    # specific/performant implementation.
    get :event do
      record.is_a?(Event) ? record : record.try(:event)
    end

    get :organizer_position do
      event&.organizer_positions&.where(user:)&.first
    end

    # Admin
    def ⚡
      user&.admin?
    end

    # Manager
    def 👔
      organizer_position&.manager?
    end

    # Organizer
    def 👥
      organizer_position.present?
    end

    # Transparency Mode
    def 🔎
      event&.is_public?
    end

  end

  class_methods do
    def get(object, &block)
      define_method object, &block
    end
  end
end
