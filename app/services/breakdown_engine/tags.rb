# frozen_string_literal: true

module BreakdownEngine
  class Tags
    def initialize(event)
      @event = event
    end

    def run
      tags = @event.tags.includes(hcb_codes: [:canonical_transactions, :canonical_pending_transactions]).each_with_object([]) do |tag, array|
        amount_cents_sum = tag.hcb_codes.sum do |hcb_code|
          [hcb_code.amount_cents, 0].min
        end
        if amount_cents_sum > 0
          array << {
            name: tag.label,
            truncated: tag.label,
            value: (amount_cents_sum * -1).to_f / 100
          }
        end
      end

      total_amount = tags.sum { |tag| tag[:value] }
      threshold = total_amount * 0.05

      if threshold > 0
        # Update tags to apply the threshold condition
        tags = tags.map do |tag|
          {
            name: tag[:name],
            truncated: tag[:truncated],
            value: (tag[:value] >= threshold ? tag[:value] : 0)
          }
        end

        # Calculate "Other" amount
        other_amount = total_amount - tags.sum { |tag| tag[:value] }
        if other_amount > 0
          tags << {
            name: "Other",
            truncated: "Other",
            value: other_amount
          }
        end
      end

      tags
    end
  end
end
