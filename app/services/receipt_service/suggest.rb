# frozen_string_literal: true

module ReceiptService
  class Suggest
    def initialize(receipt:)
      @receipt = receipt
    end

    def run!
      if @receipt.textual_content.nil?
        @receipt.extract_textual_content!

        if @receipt.textual_content.nil?
          return nil
        end
      end

      @extracted = ::ReceiptService::Extract.new(receipt: @receipt).run!

      best_match
    end

    private

    def sorted_txns
      potential_txns.map do |txn|
        {
          txn: txn,
          distance: distance(txn)
        }
      end.sort_by { |match| match[:distance] }
    end

    def best_match
      sorted_txns.first
    end

    def safe_date(month, day, year)
      begin
        Date.new(year, month, day)
      rescue Date::Error => e
        nil
      end
    end

    def distance(txn)
      weights = {
        amount_cents: 1,
        date: 100,
        card_last_four: 100,
        merchant_zip_code: 5,
        merchant_city: 5,
        merchant_phone: 5,
        merchant_name: 5
      }

      # TODO - Have order in amount_cents array matter in the distance formula
      amount_cents = best_distance(txn.amount_cents, @extracted[:amount_cents])
      date = best_distance(txn.date.to_time.to_i / 86400, @extracted[:date].map { |d| safe_date(*d) }.reject { |d| d.nil? }.map{ |d| d.to_time.to_i / 86400 })
      card_last_four = @extracted[:card_last_four].include?(txn.stripe_card.last4) ? 0 : 1

      merchant_zip_code = @receipt.textual_content.include?(txn.stripe_merchant["postal_code"]) ? 0 : 1
      merchant_city = @receipt.textual_content.downcase.include?(txn.stripe_merchant["city"].downcase) ? 0 : 1
      merchant_phone = txn.stripe_merchant["city"].gsub(/\D/, "").length > 6 && @receipt.textual_content.include?(txn.stripe_merchant["city"].gsub(/\D/, "")) ? 0 : 1
      merchant_name = @receipt.textual_content.downcase.include?(txn.stripe_merchant["name"].downcase) ? 0 : 1

      # distance formula options

      # euclidian distance
      # Math.sqrt(amount_cents**2 + date**2 + card_last_four**2)

      # manhattan distance
      # (amount_cents**1 + date**1 + card_last_four**1)**(1/1)

      # chebyshev distance
      # [amount_cents, date, card_last_four].max

      # minkowski distance
      # (amount_cents**3 + date**3 + card_last_four**3)**(1.0/3.0)

      Math.sqrt(
        (amount_cents * weights[:amount_cents])**2 +
        (date * weights[:date])**2 +
        (card_last_four * weights[:card_last_four])**2 +
        (merchant_zip_code * weights[:merchant_zip_code])**2 +
        (merchant_city * weights[:merchant_city])**2 +
        (merchant_phone * weights[:merchant_phone])**2 +
        (merchant_name * weights[:merchant_name])**2
      )
    end

    def best_distance(one_point, multiple_values)
      multiple_values.map do |value|
        (one_point - value).abs
      end.min || 100
    end

    def user
      @receipt.user
    end

    def potential_txns
      user.stripe_cards.map { |card| card.hcb_codes }.flatten.reject { |hcb_code| hcb_code.receipts.length > 0 || !hcb_code.marked_no_or_lost_receipt_at.nil? }
    end

  end
end
