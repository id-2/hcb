# frozen_string_literal: true

class LobCheckMailer < ApplicationMailer
  def undeposited
    @lob_check = params[:lob_check]

    mail to: admin_email, subject: "Check #{@lob_check.check_number} wasn't deposited & is being voided."
  end

  def undeposited_organizers
    @lob_check = params[:lob_check]
    @emails = @lob_check.event.users.map { |u| u.email }
    @event = @lob_check.event

    mail to: @emails, subject: "Your check to #{@lob_check.lob_address.name}"
  end

end
