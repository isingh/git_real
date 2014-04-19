require 'user_session'

class HomepageController < ApplicationController
  include UserSession
  before_filter :prompt_for_auth

  def index
    @repos = current_github_user.repos
  end

  def repos
    @repo_name = params[:repo_name]
    @friends = current_github_user.friend_scores3(current_github_user.handle, @repo_name)
  end
end
