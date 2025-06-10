# frozen_string_literal: true

class User
  class SendCardLockingNotificationJob < ApplicationJob
    queue_as :low
    def perform
      ::UserService::SendCardLockingNotification.new.run
    end

  end

end
