# frozen_string_literal: true

class HcbCodeMailer < ApplicationMailer
  def report(params)
    @user = params[:user]
    @hcb_code = params[:hcb_code]
    @hcb_code_url = hcb_code_url(@hcb_code)

    to = @user.email
    subject = "#{@hcb_code.event.name}: Reported Transaction. \"#{@hcb_code.memo}\""

    mail to: to,
         subject: subject,
         cc: "bank@hackclub.com"
  end
end
