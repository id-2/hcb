# frozen_string_literal: true

require "cgi"

module EventsHelper
  def dock_item(name, tooltip, icon, url, lg = false, badge = nil)
    link_to url,
            class: "dock__item #{lg && 'dock__item--lg'} tooltipped tooltipped--e",
            'aria-label': tooltip do
      (content_tag :div, class: "line-height-0 relative" do
        inline_icon(icon, size: 32, class: "primary") + (badge && badge != 0 ? content_tag(:div, badge, class: "dock__item--badge") : "")
      end) + content_tag(:span, name.html_safe, class: "line-height-3")
    end
  end

  def paypal_transfers_airtable_form_url(embed: false, event: nil, user: nil)
    # The airtable form is located within the Bank Promotions base
    form_id = "shrH9fMs5hof2HRup"
    embed_url = "https://airtable.com/embed/#{form_id}"
    url = "https://airtable.com/#{form_id}"

    prefill = []
    prefill << "prefill_Event/Project+Name=#{CGI.escape(event.name)}" if event
    prefill << "prefill_Submitter+Name=#{CGI.escape(user.full_name)}" if user
    prefill << "prefill_Submitter+Email=#{CGI.escape(user.email)}" if user

    (embed ? embed_url : url) + "?" + prefill.join("&")
  end
end
