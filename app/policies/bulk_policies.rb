# frozen_string_literal: true

# Emoji helpers for policies
module BulkPolicies
  extend ActiveSupport::Concern

  class_methods do
    def policy_for(*actions, &block)
      actions.each do |action|
        define_method(action, &block)
      end
    end
  end

end
