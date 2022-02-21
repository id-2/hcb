# frozen_string_literal: true

class PartnerLive < Partner
  validate :validate_stripe_keys_are_live_mode

  private

  include Partners::Stripe::Constants

  def validate_stripe_keys_are_live_mode

    if self.stripe_api_key.present? && !self.stripe_api_key.starts_with?(LIVE_API_KEY_PREFIX)
      errors.add(:stripe_api_key, 'must be a stripe live api key')
    end

    if self.public_stripe_api_key.present? && !self.public_stripe_api_key.starts_with?(LIVE_PUBLIC_API_KEY_PREFIX)
      errors.add(:public_stripe_api_key, 'must be a stripe live api key')
    end

  end

end
