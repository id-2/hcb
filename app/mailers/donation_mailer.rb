# frozen_string_literal: true

class DonationMailer < ApplicationMailer
  def donor_receipt
    @donation = params[:donation]
    @initial_recurring_donation = @donation.initial_recurring_donation? && !@donation.recurring_donation&.migrated_from_legacy_stripe_account?
    @purchased_product = @donation.product.present?

    mail to: @donation.email, reply_to: @donation.event.donation_reply_to_email.presence, subject: if @donation.recurring?
                                                                                                     "Receipt for your donation to #{@donation.event.name} — #{@donation.created_at.strftime("%B %Y")}"
                                                                                                   else
                                                                                                     "Receipt for your #{@purchased_product ? "purchase from" : "donation to"} #{@donation.event.name}"
                                                                                                   end
  end

  def first_donation_notification
    @donation = params[:donation]
    @emails = @donation.event.users.map { |u| u.email }
    @purchased_product = @donation.product.present?

    mail to: @emails, subject: "Congrats on receiving your first donation! 🎉"
  end

  def donation_with_message_or_product_notification
    @donation = params[:donation]
    @emails = @donation.event.users.pluck(:email)
    @purchased_product = @donation.product.present?

    mail to: @emails, subject: "You've received a donation! 🎉"
  end

end
