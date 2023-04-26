# frozen_string_literal: true

module LobCheckJob
  class Nightly < ApplicationJob
    def perform
      LobCheckService::Nightly.new.run
    end

  end
end
