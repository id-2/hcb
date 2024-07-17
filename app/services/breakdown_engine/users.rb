# frozen_string_literal: true

module BreakdownEngine
  class Users
    def initialize(event, show_all: false)
      @event = event
      @show_all = show_all
    end

    def run
      @event.organizer_positions.includes(:user)
            .each_with_object([]) do |position, array|
        amount = @event.canonical_transactions
                       .stripe_transaction
                       .joins("JOIN stripe_cardholders ON raw_stripe_transactions.stripe_transaction->>'cardholder' = stripe_cardholders.stripe_id")
                       .where(stripe_cardholders: {
                                user_id: position.user.id
                              })
                       .sum(:amount_cents).to_f / 100 * -1

        array << { name: position.user.initial_name, value: amount, position: } if amount > 0 unless @show_all
      end
    end

  end
end
