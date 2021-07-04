# As a part of the Partner Organizations system, we need to be able to give
# people access to an organization WITHOUT their active participation in
# creating a user and accepting an invite.
#
# Here's how this works:
# 1. Using an Admin account, we call Hack Club's API to create a user. This
#    returns their access_token.
# 2. With their access_token, we get their user information from Hack Club's API.
# 3. We create a User for them in Bank and store some information provided by
#    the api (access_token, admin_at, and api_id).
# 4. We skip creating an OrganizerPositionInvite, instead, we directly create
#    an OrganizerPosition. (OrganizerPositions are usually created when a user
#    accepts an invite)

module UserService
  class Create
    def initialize(email:, full_name:, phone_number:, event_id: nil)
      @email = email
      @full_name = full_name
      @phone_number = phone_number
			@event_id = event_id
    end

    def run
      raise ArgumentError if user_exists

      # create the user on Hack Club API and Bank
      user = User.new(email: remote_email)
      user.api_id = remote_user_id
      user.api_access_token = remote_access_token 
      user.admin_at = remote_admin_at
      user.full_name = @full_name
      user.phone_number = @phone_number
      user.save!

      user.reload
      @user ||= user

      return @user if @event_id.nil?

      # invite them to the org by creating an OrganizerPosition
      OrganizerPosition.create!(
        event: Event.friendly.find(@event_id),
        user: @user
      )

      @user
    end

    private

    def user_exists
      User.find_by(email: @email).present?
    end

    def get_user_access_token # will create the user on Hack Club API is it doesn't exit
      @access_token ||= ::Partners::HackclubApi::GetAccessToken.new(email: @email).run
    end

    def get_user_resp
      @get_user_resp ||= ::Partners::HackclubApi::GetUser.new(user_id: @user_id, access_token: remote_access_token).run
    end

    def remote_access_token
      get_user_access_token[:auth_token]
    end

    def remote_user_id
      get_user_resp[:id]
    end

    def remote_email
      get_user_resp[:email]
    end

    def remote_admin_at
      get_user_resp[:admin_at]
    end

    def inviter
      User.find(melanie_smith_user_id)
    end

    def melanie_smith_user_id
      2046
    end
  end
end
