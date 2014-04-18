require 'githubber'
require 'user_session'

class UsersController < ApplicationController
  include UserSession

  def auth
    redirect_to Githubber::User.auth_redirect_url
  end

  def handle_auth
    oauth_token = user_oauth_token
    unless oauth_token
      flash[:error] = "Unable to login via Github"
      redirect_to login_path and return
    end

    initiate_session(oauth_token)
    flash[:success] = "You have successfully logged in"
    redirect_to '/'
  end

  def login
  end

  def logout
    clear_session

    flash[:info] = "You have been logged out"
    redirect_to login_path
  end

  private

  def user_oauth_token
    github_auth_code ? Githubber::User.oauth_token(github_auth_code) : nil
  end

  def github_auth_code
    params[:code]
  end
end
