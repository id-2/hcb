class OrganizerPosition
  module Spending
    module AllowancesHelper
      def item_to_real_created_date(item)
        if item.is_a? CanonicalPendingTransaction
          return Time.at(item.raw_pending_stripe_transaction.stripe_transaction["created"])
        end

        return item.created_at
      end

      def sorted_spending_items(control)
        @spending_items = []
        @spending_items << control.transactions.sort_by(&:created_at).reverse! unless params[:filter] == "allowances"
        @spending_items << control.organizer_position_spending_allowances.order(created_at: :desc) unless params[:filter] == "transactions"
        @spending_items.flatten!.sort_by(&:created_at).reverse!
      end

    end

  end

end
