# frozen_string_literal: true

# Get all missing receipts + their cards for a given user:
# ReceiptableService::Missing.new(user: current_user).run
# Get 5 missing receipts for a user:
# ReceiptableService::Missing.new(user: current_user, limit: 5).run
# Get missing receipts for a given card:
# ReceiptableService::Missing.new(card: StripeCard.last).run

module ReceiptableService
  class Missing
    def initialize(user: nil, limit: nil, card: nil)
      @user = user unless user.nil?
      @limit = limit unless limit.nil?
      @card = card unless card.nil?
    end

    def run
      count = 0
      cards = Set.new
      hcb_codes = []
      hcb_codes_by_card = Hash.new { |h, k| h[k] = [] }

      cards_to_check.each do |card|
        card.hcb_codes.missing_receipt.each do |hcb_code|
          next unless hcb_code.receipt_required?
          next unless @limit.nil? || count < @limit

          cards << card
          hcb_codes << hcb_code
          hcb_codes_by_card[card] << hcb_code
          count += 1
        end
      end

      {
        count: count,
        cards: cards,
        hcb_codes: hcb_codes,
        hcb_codes_by_card: hcb_codes_by_card
      }
    end

    private

    def cards_to_check
      if @card.nil?
        stripe_cards = @user.stripe_cards
        emburse_cards = @user.emburse_cards

        (stripe_cards + emburse_cards)
      else
        [@card]
      end
    end
  end
end
