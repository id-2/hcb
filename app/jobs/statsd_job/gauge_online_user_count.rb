# frozen_string_literal: true

module StatsdJob
  class GaugeOnlineUserCount < ApplicationJob
    queue_as :default

    def perform
      StatsD.gauge("User.currently_online_count", User.currently_online.count)
    end

  end
end
