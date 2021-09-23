# frozen_string_literal: true

module SlashZService
  class Create
    def initialize(event_id:, user_id:)
      @event_id = event_id
      @user_id = user_id
    end

    def run
      return if events_open_meetings.count > 2 # limit events to a max of two concurrent meetings

      attrs = {
        event_id: @event_id,
        user_id: @user_id,
        zoom_id: remote_slash_z[:zoomID],
        started_at: remote_slash_z[:startedAt],
        ended_at: remote_slash_z[:endedAt],
        host_join_url: remote_slash_z[:hostJoinURL],
        join_url: remote_slash_z[:joinURL],
        host_key: remote_slash_z[:hostKey],
        aasm_state: begin
          case remote_slash_z[:status]
          when "OPEN"
            :open
          when "ENDED"
            :ended
          else
            nil
          end
        end
      }

      SlashZ.create!(attrs)
    end

    private

    def user
      @user ||= User.find(@user_id)
    end

    def event
      @event ||= Event.find(@event_id)
    end

    def events_open_meetings
      # get open slash z meetings that belong to this event
      event.slash_zs.open
    end

    def access_token
      Rails.application.credentials.slash_z[:access_token]
    end

    def params
      {
        userID: "BANK_#{@event_id}_#{@user_id}"

        # We'll use Slash Z's default host settings for now
        # https://marketplace.zoom.us/docs/api-reference/zoom-api/meetings/meetingcreate
        # hostSettings: {}
      }
    end

    def remote_slash_z
      @remote_slash_z ||= create_remote_slash_z
    end

    def create_remote_slash_z
      conn = Faraday.new(url: "https://slash-z.hackclub.com")

      res = conn.send(:post) do |req|
        req.url "/api/endpoints/bank/create-meeting"
        req.headers["Content-Type"] = "application/json"

        if access_token
          req.headers["Authorization"] = "Bearer #{access_token}"
        end

        req.body = params.to_json
      end

      if res.status == 401
        Airbrake.notify("Authentication problem (401) with Slash Z", res.body)
        raise ArgumentError, "A internal server error has occured."
      end

      JSON.parse(res.body, symbolize_names: true)
    end

  end
end
