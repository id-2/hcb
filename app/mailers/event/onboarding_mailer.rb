# frozen_string_literal: true
class Event
  class OnboardingMailer < ApplicationMailer
    before_action :set_event
    before_action :set_user

    before_action :ensure_event_is_not_demo

    def getting_started
      mail to: @user.email_address_with_name, subject: "👋 Welcome to HCB! Let's get started"
    end

    private

    def ensure_event_is_not_demo
      raise AbortDeliveryError if @event.demo_mode?
    end

    def set_event
      @event = params[:event]
    end

    def set_user
      @user = params[:user]
    end

  end

end
