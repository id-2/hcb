# frozen_string_literal: true

module HcbCodeService
  class PizzaGrantChargeWebhook

  include Rails.application.routes.url_helpers
    TYPE = "pizza_grant.charge"
    def initialize(hcb_code:)
      @hcb_code = hcb_code
    end

    def run
      event = @hcb_code.event
      grant = @hcb_code.stripe_card&.card_grant
      if event.id == 3340 && grant
        # 3340: https://hcb.hackclub.com/2023-pizza-grant
        # this is a transaction using a card grant card
        ::ApiService::V2::DeliverWebhook.new(
          type: TYPE,
          webhook_url: "https://example.com", # needs to be updated, waiting for @jdogcoder.
          data: JSON.generate(
            "url": hcb_code_url(@hcb_code),
            "amount_cents": @hcb_code.amount_cents,
            "merchant": {
              "name": @hcb_code.stripe_merchant["name"],
              "category": @hcb_code.stripe_merchant["category"],
              "merchant_id": @hcb_code.stripe_merchant["network_id"]
            },
            "user": {
              "id": grant.user.public_id,
              "name": grant.user.full_name
            },
            "grant": {
              "url": card_grant_url(grant)
            }
          ),
          secret: "bbqOFdinosaurs" # how do we want to do this? this is just a filler secret.
        ).run
      end
    end

  end
end
