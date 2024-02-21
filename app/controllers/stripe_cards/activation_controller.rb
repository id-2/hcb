# frozen_string_literal: true

module StripeCards
  class ActivationController < ApplicationController
    # Form for activating a card
    def new
      skip_authorization
    end

    # Submit a last4 for activation
    def create
      @card = current_user.stripe_cardholder.stripe_cards.find_by(last4: params[:last4])

      if @card.nil?
        flash[:error] = "Card not found"
        skip_authorization
        redirect_back fallback_location: stripe_cards_activation_path and return
      end

      authorize @card

      if @card.activated?
        flash[:error] = "Card already activated"
        redirect_to @card and return
      end

      if @card.replacement_for
        suppress(Stripe::InvalidRequestError) do
          @card.replacement_for.cancel!
        end
      end

      @card.update(activated: true)
      @card.defrost!

      flash[:success] = "Card activated!"
      redirect_to @card
    end

  end
end
