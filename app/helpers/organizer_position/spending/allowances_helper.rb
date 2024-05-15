module OrganizerPosition::Spending::AllowancesHelper

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
    if items.count == 0
      concat blankslate("Nothing to see here")
    else
      capture do
        concat(content_tag(:div, class: "table-container") do
          concat(content_tag(:table) do
            concat(content_tag(:thead) do
              concat(content_tag(:tr) do
                concat content_tag(:th, "Amount")
                concat content_tag(:th, "Memo")
                concat content_tag(:th, "Created by")
                concat content_tag(:th, "Date")
              end)
            end)
            concat(content_tag(:tbody) do
              items.each do |i|
                concat render_spending_item(i)
              end
            end)
          end)
        end)
      end
    end
  end

  def render_spending_item(item)
    item_user = item.is_a?(OrganizerPosition::Spending::Allowance) ? item.authorized_by.user : item.stripe_cardholder.user

    capture do
      concat(content_tag(:tr, class: item.is_a?(OrganizerPosition::Spending::Allowance) ? "transaction--positive" : "transaction--negative") do
        concat content_tag(:td, render_money(item.amount_cents))
        concat content_tag(:td, item.memo, style: "max-width: 400px; overflow: hidden; text-overflow: elipsis;")
        concat(content_tag(:td, class: "flex items-center g1") do
          concat avatar_for(item_user, 24)
          concat item_user.name
        end)
        concat content_tag(:td, format_date(item.created_at))
      end)
    end
  end

end
