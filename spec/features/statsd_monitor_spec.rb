# frozen_string_literal: true

require "rails_helper"

RSpec.configure do |config|
  config.include StatsD::Instrument::Matchers
end

RSpec.describe "Monitoring requests with StatsD", type: :feature do
  context "trigger_statsd_increment" do
    it "will pass if there is exactly one matching StatsD call" do
      expect { StatsD.increment("counter") }.to trigger_statsd_increment("counter")
    end

    it "will pass if it matches the correct number of times" do
      expect {
        2.times do
          StatsD.increment("counter")
        end
      }.to trigger_statsd_increment("counter", times: 2)
    end

    it "will pass if it matches argument" do
      expect {
        StatsD.measure("counter", 0.3001)
      }.to trigger_statsd_measure("counter", value: be_between(0.29, 0.31))
    end

    it "will pass if there is no matching StatsD call on negative expectation" do
      expect { StatsD.increment("other_counter") }.not_to trigger_statsd_increment("counter")
    end

  end
end
