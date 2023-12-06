# frozen_string_literal: true

class MailboxMailer < ApplicationMailer
  def forward(inbound_email:, to:)
    mail to:, subject: "Fwd: #{inbound_email.mail.subject} (#{inbound_email.mail.to.first})", reply_to: inbound_email.mail.from, content: inbound_email.mail.content
  end

end
