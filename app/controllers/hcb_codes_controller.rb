# frozen_string_literal: true

class HcbCodesController < ApplicationController
  skip_before_action :signed_in_user, only: [:receipt, :attach_receipt]

  def show
    @hcb_code = HcbCode.find_by(hcb_code: params[:id]) || HcbCode.find(params[:id])

    authorize @hcb_code

    @event = @hcb_code.event
  end

  def comment
    @hcb_code = HcbCode.find(params[:id])

    authorize @hcb_code

    attrs = {
      hcb_code_id: @hcb_code.id,
      content: params[:content],
      file: params[:file],
      admin_only: params[:admin_only],
      current_user: current_user
    }
    ::HcbCodeService::Comment::Create.new(attrs).run

    redirect_to params[:redirect_url]
  rescue => e
    redirect_to params[:redirect_url], flash: { error: e.message }
  end

  def receipt
    @hcb_code = HcbCode.find(params[:id])

    authorize @hcb_code

    attrs = {
      hcb_code_id: @hcb_code.id,
      file: params[:file],
      current_user: current_user
    }
    ::HcbCodeService::Receipt::Create.new(attrs).run

    redirect_to params[:redirect_url]
  rescue => e
    Airbrake.notify(e)

    redirect_to params[:redirect_url], flash: { error: e.message }
  end

  def attach_receipt
    @hcb_code = HcbCode.find(params[:id])

    authorize @hcb_code
  end

  def report
    @hcb_code = HcbCode.find(params[:id])
    authorize @hcb_code

    report_mailer_params = {
      user: current_user,
      hcb_code: @hcb_code
    }

    begin
      HcbCodeMailer.report(report_mailer_params).deliver_later
      redirect_to @hcb_code, flash: { success: "Transaction reported. Please check your email." }
    rescue => e
      Airbrake.notify(e)
      redirect_to @hcb_code, flash: { error: "There was an error reporting this transaction, please contact bank@hackclub.com" }
    end
  end
end
