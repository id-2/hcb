module Partners
  module HackclubApi
    class GetAccessToken
      def initialize(email:)
        @email = email
      end

      def run
        ::BankApiService.req(:post, url, attrs, access_token)
      end

      private

      def attrs
        {
          email: @email
        }
      end

      def url
        "/v1/users/auth_on_behalf"
      end

      def access_token # brittle. this requires Mel's Hack Club API access token to be valid
        User.find(melanie_smith_user_id).api_access_token # we can use any admin's api token here
      end

      def melanie_smith_user_id
        2046
      end
    end
  end
end
