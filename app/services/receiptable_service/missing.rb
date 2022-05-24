# frozen_string_literal: true

# Get all missing receipts + their cards for a given user:
# ReceiptableService::Missing.new(user: current_user).run
# Get last 5 missing receipts for a user:
# ReceiptableService::Missing.new(user: current_user, limit: 5).run
module ReceiptableService
  class Missing
    def initialize(user: nil, limit: nil, card: nil)
      @user = user
      @limit = limit unless limit.nil?
    end

    def run
      results = {}
      count = 0

      stripe_cards = @user.stripe_cards
      emburse_cards = @user.emburse_cards
      (stripe_cards + emburse_cards).each do |card|
        card.hcb_codes.missing_receipt.each do |hcb_code|
          next unless hcb_code.receipt_required?
          next unless @limit.nil? || count < @limit

          results[card] ||= []
          results[card] << hcb_code

          count += 1
        end
      end

      results
    end

  end
end
