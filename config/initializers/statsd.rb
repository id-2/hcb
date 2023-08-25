# frozen_string_literal: true

Rails.application.config do
  # StatsD config here
  StatsD::Instrument::Client.attr_writer :prefix
  ENV["STATSD_ENV"] = "#{Rails.env}.bank"
  ENV["STATSD_ADDR"] = "telemetry.hackclub.com:8125"

  StatsD::Instrument::Environment.setup
end
