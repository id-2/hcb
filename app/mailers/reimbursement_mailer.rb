# frozen_string_literal: true

class ReimbursementMailer < ApplicationMailer
  def invitation
    @report = params[:report]

    mail to: @report.user.email, subject: "Get reimbursed by #{@report.event.name} for #{@report.name}", from: email_address_with_name("hcb@hackclub.com", "#{@report.event.name} via HCB")
  end

  def reimbursement_approved
    @report = params[:report]

    mail to: @report.user.email, subject: "#{@report.name}: Reimbursement Approved", from: email_address_with_name("hcb@hackclub.com", "#{@report.event.name} via HCB")
  end

  def rejected
    @report = params[:report]
  
    mail to: @report.user.email, subject: "#{@report.name}: Rejected", from: email_address_with_name("hcb@hackclub.com", "#{@report.event.name} via HCB")
  end

  def review_requested
    @report = params[:report]

    mail to: @report.event.users.pluck(:email).excluding(@report.user.email), subject: "#{@report.name}: Review Requested"
  end

  def expense_approved
    @report = params[:report]
    @expense = params[:expense]

    mail to: @report.user.email, subject: "#{@expense.memo} (#{@report.name}): Expense Approved", from: email_address_with_name("hcb@hackclub.com", "#{@report.event.name} via HCB")
  end

end
