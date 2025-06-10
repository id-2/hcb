# frozen_string_literal: true

module UserService
  class UpdateCardLocking
    def initialize(user:)
      @user = user
    end

    def run
      return unless Flipper.enabled?(:card_locking_2025_06_09, @user)

      count = @user.transactions_missing_receipt(since: Date.parse("2025-06-09")).count

      if count >= 10 && !@user.cards_locked?
        CardLockingMailer.cards_locked(email: @user.email, missing_receipts: count).deliver_later
      end

      cards_locked = count >= 10
      @user.update!(cards_locked:)
    end

  end
end
