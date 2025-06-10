# frozen_string_literal: true

class User
  class UpdateCardLockingJob < ApplicationJob
    queue_as :low
    def perform
      ::UserService::UpdateCardLocking.new.run
    end

  end

end
