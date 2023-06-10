# frozen_string_literal: true

module ReceiptService
  class Suggest
    def initialize(receipt:)
      @receipt = receipt
    end

    def run!
      @extracted = ::ReceiptService::Extract.new(receipt: @receipt).run!

      return nil if @extracted.nil?

      transaction_distances
    end

    def run_with_details!
      @extracted = ::ReceiptService::Extract.new(receipt: @receipt).run!

      return nil if @extracted.nil?

      transaction_distances_with_details
    end

    def sorted_transactions
      transaction_distances.sort_by { |match| match[:distance] }
    end

    def best_match
      sorted_transactions.first
    end

    private

    def transaction_distances
      potential_txns.map do |txn|
        {
          hcb_code: txn,
          distance: distance(txn)
        }
      end
    end

    def transaction_distances_with_details
      potential_txns.map do |txn|
        {
          hcb_code: txn,
          distance: distance(txn),
          details: distances_hash(txn)
        }
      end
    end

    def safe_date(month, day, year)
      begin
        Date.new(year, month, day)
      rescue Date::Error => e
        nil
      end
    end

    def distances_hash(txn)
      # TODO - Have order in amount_cents array matter in the distance formula

      puts txn.memo
      puts "transaction memo"

      ap @extracted
      puts "extracted"

      {
        amount_cents: best_distance(txn.amount_cents, @extracted[:amount_cents]) + rand(),
        date: best_distance(txn.date.to_time.to_i / 86400, @extracted[:date].map { |d| safe_date(*d) }.reject { |d| d.nil? }.map{ |d| d.to_time.to_i / 86400 }),
        card_last_four: @extracted[:card_last_four].include?(txn.stripe_card.last4) ? 0 : 1,

        merchant_zip_code: @extracted[:textual_content].include?(txn.stripe_merchant["postal_code"]) ? 0 : 1,
        merchant_city: @extracted[:textual_content].downcase.include?(txn.stripe_merchant["city"].downcase) ? 0 : 1,
        merchant_phone: txn.stripe_merchant["city"].gsub(/\D/, "").length > 6 && @extracted[:textual_content].include?(txn.stripe_merchant["city"].gsub(/\D/, "")) ? 0 : 1,
        merchant_name: @extracted[:textual_content].downcase.include?(txn.stripe_merchant["name"].downcase) ? 0 : 1,
      }
    end

    def distance(txn)
      weights = {
        amount_cents: 100,
        date: 100,
        card_last_four: 100,
        merchant_zip_code: 5,
        merchant_city: 5,
        merchant_phone: 5,
        merchant_name: 5
      }

      distances = distances_hash(txn)

      # distance formula options

      # euclidian distance
      # Math.sqrt(amount_cents**2 + date**2 + card_last_four**2)

      # manhattan distance
      # (amount_cents**1 + date**1 + card_last_four**1)**(1/1)

      # chebyshev distance
      # [amount_cents, date, card_last_four].max

      # minkowski distance
      # (amount_cents**3 + date**3 + card_last_four**3)**(1.0/3.0)

      sqrt = Math.sqrt(
        (distances[:amount_cents] * weights[:amount_cents])**2 +
        (distances[:date] * weights[:date])**2 +
        (distances[:card_last_four] * weights[:card_last_four])**2 +
        (distances[:merchant_zip_code] * weights[:merchant_zip_code])**2 +
        (distances[:merchant_city] * weights[:merchant_city])**2 +
        (distances[:merchant_phone] * weights[:merchant_phone])**2 +
        (distances[:merchant_name] * weights[:merchant_name])**2
      )

      puts sqrt
      puts "suggest:sqrt"

      sqrt
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
      # TODO: Filter out declined transactions and transactions with $0 amount
      user.stripe_cards.flat_map(&:hcb_codes).select { |hcb_code| hcb_code.needs_receipt? }
    end

  end
end
