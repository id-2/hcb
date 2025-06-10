# frozen_string_literal: true

module UserService
  class SendCardLockingNotification
    def initialize(user:)
      @user = user
    end

    def run
      return unless Flipper.enabled?(:card_locking_2025_06_09, @user)

      count = @user.transactions_missing_receipt(since: Date.parse("2025-06-09")).count

      if count.in?([5, 7, 9])
        CardLockingMailer.warning(email: @user.email, missing_receipts: count).deliver_later
      end
    end

  end
end
