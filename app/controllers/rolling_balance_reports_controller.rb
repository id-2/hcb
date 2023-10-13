# frozen_string_literal: true

class RollingBalanceReportsController < ApplicationController
  skip_after_action :verify_authorized # do not force pundit
  before_action :signed_in_admin

  def create
    report = RollingBalanceReport.create!(creator: current_user)
    report.run!

    flash[:notice] = "Your report is being generated. We'll email you when it's ready."
    redirect_to root_path
  end

end
