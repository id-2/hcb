# frozen_string_literal: true

module ReceiptService
  class Suggest
    def initialize(receipt:)
      @receipt = receipt
    end

    def run!(include_details: false)
      return nil if user.nil?
      return nil unless @receipt.has_textual_content?

      @extracted = ::ReceiptService::Extract.new(receipt: @receipt).run!

      byebug

      transaction_distances(include_details:)
    end

    def distance(txn)
      return if @extracted.nil?

      distances = {
        amount_cents: {
          value: begin
            diff = (txn.amount_cents - @extracted.amount_cents).abs
            diff == 0 ? 0 : [10 * Math.log((diff + 1) / 3.0) + 30, 20].max
          end,
          weight: 100,
        },
        card_last_four: {
          value: @extracted.card_last_four == txn.card&.last4,
          weight: 100,
        },
        date: {
          value: @extracted.date.to_date == txn.date,
          weight: 100,
        },
        merchant_zip_code: {
          value: @extracted.merchant_zip_code == txn.postal_code,
          weight: 50,
        },
        merchant_name: {
          value: @extracted.merchant_name == txn.stripe_merchant.name,
          weight: 100,
        }
      }

      distances.each do |feature, *value|
        puts value

        # (value.in? [true, false] ? (value ? 1 : 0) : value) * weight
      end

      byebug
    end

    def sorted_transactions
      transaction_distances.sort_by { |match| match[:distance] }
    end

    def best_match
      sorted_transactions.first
    end

    private

    def transaction_distances(include_details: false)
      potential_txns.map do |txn|
        {
          hcb_code: txn,
          distance: distance(txn),
          details: include_details ? distances_hash(txn) : nil
        }
      end
    end

    # def distance(txn)
    #   total_weight = self.class.weights.values.sum
    #   weight_applied = 0
    #   distance = 0

    #   self.class.weights.each do |key, weight|
    #     unless distances[key].nil?
    #       weight_applied += weight
    #       distance += (distances[key] * weight)**2
    #     end
    #   end

    #   # distance formula options

    #   # euclidian distance
    #   # Math.sqrt(amount_cents**2 + date**2 + card_last_four**2)

    #   # manhattan distance
    #   # (amount_cents**1 + date**1 + card_last_four**1)**(1/1)

    #   # chebyshev distance
    #   # [amount_cents, date, card_last_four].max

    #   # minkowski distance
    #   # (amount_cents**3 + date**3 + card_last_four**3)**(1.0/3.0)

    #   distance *= (total_weight / weight_applied) # scale up to account for missing weights

    #   Math.sqrt(distance)
    # end

    def best_distance(one_point, multiple_values)
      multiple_values.map do |value|
        (one_point - value).abs
      end.min || 100
    end

    def user
      @receipt.user
    end

    def potential_txns
      user.stripe_cards.flat_map(&:hcb_codes).select { |hcb_code| hcb_code.needs_receipt? }
    end

  end
end
