# frozen_string_literal: true

require "csv"
require "benchmark"

class RollingBalanceReportJob < ApplicationJob
  queue_as :low_priority

  def perform(rolling_balance_report)
    @rbr = rolling_balance_report

    time = Benchmark.measure do
      @rbr.csv_files.attach(io: StringIO.new(generate_report(:balance)), filename: "rolling_balance_report.csv", content_type: "text/csv")
      @rbr.csv_files.attach(io: StringIO.new(generate_report(:revenue)), filename: "rolling_fee_revenue_report.csv", content_type: "text/csv")
      @rbr.csv_files.attach(io: StringIO.new(generate_report(:raised)), filename: "rolling_raised_report.csv", content_type: "text/csv")
      @rbr.csv_files.attach(io: StringIO.new(generate_report(:expenses)), filename: "rolling_expenses_report.csv", content_type: "text/csv")
    end
    time.real
    @rbr.job_runtime_seconds = time.real
    @rbr.save!

    @rbr.succeed!

  rescue => e
    @rbr.error_log.attach(io: StringIO.new(e.message), filename: "error.log", content_type: "text/plain")

    @rbr.failure!
  end

  private

  def generate_report(report_type)
    CSV.generate do |csv|
      csv << ["Event", "Event ID", list_of_months].flatten
      Event.all.map do |event|
        csv << [
          event.name,
          event.id,
          list_of_months.map do |date|
            balance_for(event, date)[report_type]
          end
        ].flatten
      end
    end


  end

  def balance_for(event, date)
    txs = event.canonical_transactions.where(date: ..date)

    return {
      raised: to_usd(txs.revenue.sum(:amount_cents)),
      expenses: to_usd(txs.expense.sum(:amount_cents)),
      balance: to_usd(txs.sum(:amount_cents)),
      revenue: to_usd(txs.includes(:fees).sum("amount_cents_as_decimal").to_i),
    }
  end

  def to_usd(cents)
    (cents / 100).to_money
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
