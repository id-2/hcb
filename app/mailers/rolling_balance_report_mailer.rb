class RollingBalanceReportMailer < ApplicationMailer
  default to: -> { @rolling_balance_report.creator.email }
  before_action :set_rolling_balance_report
  after_action :update_rolling_balance_report

  def success
    attachments["report.csv"] = @rolling_balance_report.csv_file.open
    mail subject: "Your rolling balance report is ready"
  end

  def failure
    attachments["error.log"] = @rolling_balance_report.error_log.open
    mail subject: "Your rolling balance report has failed"
  end

  private

  def set_rolling_balance_report
    @rolling_balance_report = params[:rolling_balance_report]
  end

  def update_rolling_balance_report
    @rolling_balance_report.sleep!
  end
end
