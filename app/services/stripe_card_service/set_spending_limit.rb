# frozen_string_literal: true

module StripeCardService
  class SetSpendingLimit
    def initialize(stripe_card_id:, amount:, interval:, has_spending_limit: true)
      @stripe_card_id = stripe_card_id

      @amount = amount.to_i
      @interval = interval
      @has_spending_limit = has_spending_limit
    end

    def run
      raise ArgumentError, "Amount can not be equal to 0, freeze the card instead!" if amount == 0 # Stripe doesn't allow for 0 amount spending limits
      raise ArgumentError, "Amount can not be less than 0" if amount < 0
      raise ArgumentError, "Amount is too high. Do you really have that much? 💸" if amount > max_amount
      raise ArgumentError, "Invalid interval" unless valid_intervals.include? interval

      ActiveRecord::Base.transaction do
        card = StripeCard.find(@stripe_card_id)

        ::StripeService::Issuing::Card.update(card.stripe_id, stripe_update_attr)

        card.update_attribute(:stripe_spending_controls_spending_limits_amount, @amount)
        card.update_attribute(:stripe_spending_controls_spending_limits_interval, @interval)
        card.update_attribute(:has_spending_limit, @has_spending_limit)

        card
      end
    end

    private

    def stripe_update_attr
      {
        spending_controls: {
          spending_limits: {
            amount: @amount,
            interval: @interval
          }
        }
      }
    end

    def max_amount
      StripeCard.spending_limit_max_amount
    end

    def valid_intervals
      StripeCard.spending_limit_intervals
    end
  end
end
