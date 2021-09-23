# frozen_string_literal: true

# The purpose of this service is to sync the remote Slash Z meeting status to Bank's copy

module SlashZService
  class Sync

    def initialize
    end

    def run
      # Sync all open meetings
      open_meetings.each do |slash_z|
        begin
          sync(slash_z)
        rescue => e
          Airbrake.notify(e)
        end
      end
    end

    private

    def open_meetings
      SlashZ.open
    end

    def access_token
      Rails.application.credentials.slash_z[:access_token]
    end

    def sync(slash_z)
      remote_slash_z = get_remote_slash_z(slash_z)

      if remote_slash_z[:status] == "ENDED"
        slash_z.mark_ended!
      end

      slash_z
    end

    def get_remote_slash_z(slash_z)
      conn = Faraday.new(url: "https://slash-z.hackclub.com")

      res = conn.send(:post) do |req|
        req.url "/api/endpoints/bank/get-meeting"
        req.headers["Content-Type"] = "application/json"

        if access_token
          req.headers["Authorization"] = "Bearer #{access_token}"
        end

        req.body = {
          zoomID: slash_z.zoom_id
        }
      end

      if res.status == 401
        Airbrake.notify("Authentication problem (401) with Slash Z", res.body)
        raise ArgumentError, "A internal server error has occured."
      end

      JSON.parse(res.body, symbolize_names: true)
    end

  end
end
