require 'githubber'
require 'user_session'

class UsersController < ApplicationController
  include UserSession

  def auth
    redirect_to Githubber::User.auth_redirect_url
  end

  def handle_auth
    oauth_token = user_oauth_token
    raise "Unable to authorize" unless oauth_token

    initiate_session(oauth_token)
    redirect_to '/'
  end

  private

  def user_oauth_token
    github_auth_code ? Githubber::User.oauth_token(github_auth_code) : nil
  end

  def github_auth_code
    params[:code]
  end
end
