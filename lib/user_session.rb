require 'githubber'

module UserSession
  extend ActiveSupport::Concern

  def populate_session(token, handle)
    session[:uoat] = token
    session[:guh] = handle
  end

  def initiate_session(token)
    user = github_user(token)
    init_github_profile(user)
    populate_session(token, user.handle)
    return
  end

  def init_github_profile(user)
    profile = GithubProfile.where(handle: user.handle).first_or_initialize
    profile.oauth_token = user.oauth_token
    profile.name = user.name
    profile.avatar_url = user.avatar_url

    profile.save!
  end

  def github_user(token)
    Githubber::User.new(token)
  end

  def is_logged_in?
    session[:guh].present?
  end

  def current_user_profile
    @current_user ||= GithubProfile.where(handle: session[:guh]).first
  end

  def prompt_for_auth
    redirect_to login_path unless is_logged_in?
  end

  def clear_session
    reset_session
  end
end
