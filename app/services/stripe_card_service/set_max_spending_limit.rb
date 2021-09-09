# frozen_string_literal: true

module StripeCardService
  class SetMaxSpendingLimit
    def initialize(stripe_card_id:)
      @stripe_card_id = stripe_card_id
    end

    def run
      ::StripeCardService::SetSpendingLimit.new(attr).run
    end

    private

    def attr
      {
        stripe_card_id: @stripe_card_id,
        amount: max_amount,
        interval: interval
        has_spending_limit: false
      }
    end

    def max_amount
      StripeCard.spending_limit_max_amount
    end

    def interval
      "per_authorization"
    end
  end
end
