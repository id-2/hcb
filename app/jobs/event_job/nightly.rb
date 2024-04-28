# frozen_string_literal: true

module EventJob
  class Nightly < ApplicationJob
    queue_as :low
    def perform
      ::EventService::Nightly.new.run
    end

  end
end
