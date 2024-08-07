# frozen_string_literal: true

module Events
    class ApplicationsController < ApplicationController
      def new
        skip_authorization
        @no_app_shell = true
      end

      def create
        skip_authorization

        application = Event::Application.create!(
          accommodations: params[:accommodations],
          contact_option: params[:contact_option],
          event_address_postal_code: params[:event_address_postal_code],
          event_address_country_code_iso3166: params[:event_address_country_code_iso3166],
          event_description: params[:event_description],
          event_name: params[:event_name],
          event_website: params[:event_website],
          existing_user: params[:existing_user],
          user_first_name: params[:first_name],
          user_last_name: params[:last_name],
          referrer: params[:referrer],
          slack_username: params[:slack_username],
          transparent: params[:transparent],
          user_birthday: params[:user_birthday],
          user_email: params[:user_email],
          user_phone: params[:user_phone],
        )

        puts "theacpplicationis", application.inspect

        user_email = current_user&.email || params[:user_email]
        success = true
        failure_message = ""

        begin
          ActiveRecord::Base.transaction do
            event = application.create_event!
            event.demo_mode_limit_email = user_email unless current_user.admin?
            OrganizerPositionInviteService::Create.new(
              event:,
              sender: current_user || User.find_by(email: "bank@hackclub.com"),
              user_email:,
              initial: true
            ).run!
          end
        rescue => e
          puts "THERERRORISE", e
          success = false
          failure_message = e.message
        end

        application.create_airtable_record if Rails.env.production?

        if current_user
          respond_to do |format|
            format.turbo_stream do
              render turbo_stream: turbo_stream.replace(
                "application_response_stream",
                partial: success ? "apply_success" : "apply_failure",
                locals: {}
              )
            end
          end
        else
          redirect_to event_path(event)
        end
      end

    end
  end
