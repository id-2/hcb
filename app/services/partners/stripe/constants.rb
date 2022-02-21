# frozen_string_literal: true

module Partners
  module Stripe
    module Constants
      # Secret API Key
      LIVE_API_KEY_PREFIX = 'sk_live'.freeze
      TEST_API_KEY_PREFIX = 'sk_test'.freeze

      # Public API Key
      LIVE_PUBLIC_API_KEY_PREFIX = 'pk_live'.freeze
      TEST_PUBLIC_API_KEY_PREFIX = 'pk_test'.freeze

    end
  end
end
