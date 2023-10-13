# frozen_string_literal: true

class RollingBalanceReportMailer < ApplicationMailer
  default to: -> { @rolling_balance_report.creator.email }
  before_action :set_rolling_balance_report, :set_attachments
  after_action :update_rolling_balance_report

  def success
    mail subject: "Your rolling balance report is ready"
  end

  def failure
    mail subject: "Your rolling balance report has failed"
  end

  private

  def set_rolling_balance_report
    @rolling_balance_report = params[:rolling_balance_report]
  end

  def set_attachments
    attachments["error.log"] = @rolling_balance_report.error_log.download if @rolling_balance_report.error_log.attached?

    @rolling_balance_report.csv_files.each do |csv_file|
      attachments[csv_file.filename.to_s] = csv_file.download
    end
  end

  def update_rolling_balance_report
    @rolling_balance_report.sleep!
  end

end
