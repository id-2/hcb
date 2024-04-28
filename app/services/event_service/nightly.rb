# frozen_string_literal: true

module EventService
  class Nightly
    def run
      save_service_level
    end

    private

    def save_service_level
      Event.all.map do |event|
        event.update!(service_level: event.computed_service_level)
      end
    end

  end
end
