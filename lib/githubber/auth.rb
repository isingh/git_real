module Githubber
  module Auth
    extend ActiveSupport::Concern

    module ClassMethods
      def auth_redirect_url
        Github.new.authorize_url(
          redirect_uri: ENV['GITHUB_REDIRECT_URL'],
          scope: 'repo'
        )
      end

      def oauth_token(auth_code)
        Github.new.get_token(auth_code).try(:token)
      end

      def github_user(oauth_token)
        Github.new(oauth_token: oauth_token).users.get('self')
      end
    end
  end
end
