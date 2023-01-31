# frozen_string_literal: true

module UserService
  module CanOpenDemoMode
    def can_open_demo_mode?(email_address)
      user = User.find_by_email email_address

      user.nil? || user.can_open_demo_mode?
    end
  end
end
