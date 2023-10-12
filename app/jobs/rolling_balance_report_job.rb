require "csv"
require "benchmark"

class RollingBalanceReportJob < ApplicationJob
  queue_as :low_priority

  def perform(rolling_balance_report)
    @rolling_balance_report = rolling_balance_report

    # time = Benchmark.measure do
    #   generate_report
    # end
    # time.real
    # @rolling_balance_report.job_runtime_seconds = time.real
    # @rolling_balance_report.save!

    @rolling_balance_report.csv_file.attach(
      io: StringIO.new(example_csv),
      filename: "rolling_balance_report.csv",
      content_type: "text/csv"
    )

    @rolling_balance_report.succeed!
  rescue StandardError => e
    @rolling_balance_report.error_log.attach(
      io: StringIO.new(e.message),
      filename: "error.log",
      content_type: "text/plain"
    )
    @rolling_balance_report.failure!
  end

  private

  def example_csv
    csv_string = CSV.generate do |csv|
      csv << ["row", "of", "CSV", "data"]
      csv << ["another", "row"]
    end
  end

  def generate_report
    Event.all.map do |event|
      list_of_months.map do |date|
        {
          event: event.name,
          values: balance_for(event, date)
        }
      end
    end
  end

  def balance_for(event, date)
    txs = event.canonical_transactions.where(date: ..date)

    return {
      raised: txs.revenue.sum(:amount_cents),
      expenses: txs.expense.sum(:amount_cents),
      balance: txs.sum(:amount_cents),
      revenue: txs.includes(:fees).sum("amount_cents_as_decimal").to_i,
    }
  end

  def list_of_months
    cursor_date = Date.parse("2015-01-01")
    months = []
    while cursor_date < Date.today
      months << cursor_date
      cursor_date = cursor_date.next_month
    end

    months
  end
end