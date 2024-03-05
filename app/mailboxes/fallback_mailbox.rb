# frozen_string_literal: true

class FallbackMailbox < ApplicationMailbox
  # mail --> Mail object, this actual email
  # inbound_email => ActionMailbox::InboundEmail record --> the active storage record

  blacklist = ["mailer-daemon@amazonses.com"]

  def process
    return if (blacklist & from.collect(&:downcase)).any?
    bounce_with MailboxMailer.forward(inbound_email:, to: "hcb@hackclub.com")
  end

end
