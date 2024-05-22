module OrganizerPosition::Spending::AllowancesHelper

  def item_to_real_created_date(item)
    if item.is_a? CanonicalPendingTransaction
      return Time.at(item.raw_pending_stripe_transaction.stripe_transaction["created"])
    end

    return item.created_at
  end

  def sorted_spending_items(control)
    transactions = control.transactions
    allowances = control.organizer_position_spending_allowances

    if !allowances || params[:filter] == "transactions"
      @spending_items = transactions.sort_by(&:created_at).reverse
    elsif !transactions || params[:filter] == "allowances"
      @spending_items = allowances.order(created_at: :desc)
    else
      @spending_items = (transactions + allowances).sort_by(&:created_at).reverse
    end
  end
end
