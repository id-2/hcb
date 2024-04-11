# frozen_string_literal: true

class GustoService
  ENVIRONMENT = Rails.env.production? ? :production : :sandbox
  
  def self.company
    "1aafae3b-c6ef-4a57-9724-0bb2f86829e9"
  end

  def self.conn
    @conn ||= Faraday.new url: "https://api.gusto-demo.com" do |f|
      f.request :url_encoded
      f.response :raise_error
      f.response :json
      f.response :logger do | logger |
        def logger.debug *args; end
      end
    end
  end

  def self.get(url, params = {})
    conn.get(url, params, { "Authorization" => "Bearer #{self.access_token}" }).body
  end

  def self.post(url, params = {})
    puts params
    conn.post(url, params, { "Authorization" => "Bearer #{self.access_token}" }).body
  end

  def self.put(url, params = {})
    conn.put(url, params, { "Authorization" => "Bearer #{self.access_token}" }).body
  end
  
  def self.create_contractor_position(user, event)
    gusto_contractor = Gusto::Contractor.find_or_create_by(user_id: user.id)
    gusto_department = Gusto::Department.find_or_create_by(event_id: event.id)
    ContractorPosition.create(gusto_contractor:, event:)
    add_contractor_to_department(gusto_department, gusto_contractor)
  end
  
  def self.add_contractor_to_department(gusto_department, gusto_contractor)
    response = put("/v1/departments/#{gusto_department.gusto_id}/add", {
      contractors: [
        { uuid: gusto_contractor.gusto_id }
      ],
      version: gusto_department.gusto_version
    })
    gusto_department.update(gusto_version: response["version"])
  end
  
  def self.access_token
    current = Gusto::AccessToken.last
    if current.expires_at < Time.now
      response = conn.post(
        "/oauth/token",
        {
          client_id: "",
          client_secret: "",
          refresh_token: current.refresh_token,
          grant_type: "refresh_token"
        }
      ).body
      new = Gusto::AccessToken.create(
        access_token: response["access_token"],
        refresh_token: response["refresh_token"],
        expires_at: 5.minutes.from_now
      )
    end
    current.access_token
  end

end
