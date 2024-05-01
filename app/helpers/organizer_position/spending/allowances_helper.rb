module OrganizerPosition::Spending::AllowancesHelper

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
