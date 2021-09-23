# frozen_string_literal: true

module SlashZJob
  class Sync < ApplicationJob
    def perform
      SlashZService::Sync.new.run
    end
  end
end
