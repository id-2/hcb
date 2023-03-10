# frozen_string_literal: true

module StripeCardholderService
  class AcceptTerms
    def initialize(cardholder:, ip:, user_agent: nil)
      @cardholder = cardholder
      @ip = ip
      @user_agent = user_agent
    end

    def run
      ::StripeService::Issuing::Cardholder.update(@cardholder.stripe_id, attrs)
    end

    private

    def attrs
      @attrs ||= {
        individual: {
          card_issuing: {
            user_terms_acceptance: {
              date: DateTime.now.to_i,
              ip: @ip,
              user_agent: @user_agent
            }
          }
        }
      }
    end
  end
end
