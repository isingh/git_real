require 'githubber/auth'
require 'githubber/repo'

module Githubber
  class User
    include Githubber::Auth
    include Githubber::Repo

    attr_accessor :user, :oauth_token, :github_api

    def initialize(token)
      self.oauth_token = token
      self.user = Githubber::User.github_user(oauth_token)
      self.github_api = Github.new(oauth_token: token)
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

