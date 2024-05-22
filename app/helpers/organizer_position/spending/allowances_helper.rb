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

  def render_spending_items(items)
    if items.nil? || items.count == 0
      concat blankslate("Nothing to see here")
    else
      capture do
        concat(content_tag(:div, class: "table-container") do
          concat(content_tag(:table) do
            concat(content_tag(:thead) do
              concat(content_tag(:tr) do
                concat content_tag(:th, "Date")
                concat content_tag(:th, "Memo")
                concat content_tag(:th, "Created by")
                concat content_tag(:th, "Amount")
              end)
            end)
            concat(content_tag(:tbody) do
              items.each do |i|
                concat(render("organizer_positions/spending/controls/spending_item", item: i))
                # concat render_spending_item(i)
              end
            end)
          end)
        end)
      end
    end
  end

end
