require 'githubber/auth'

module Githubber
  class User
    include Githubber::Auth
    attr_accessor :user, :oauth_token

    def initialize(token)
      self.oauth_token = token
      self.user = Githubber::User.github_user(oauth_token)
    end

    def handle
      self.user.login
    end

    def name
      self.user.name
    end

    def avatar_url
      self.user.avatar_url
    end
  end
end

