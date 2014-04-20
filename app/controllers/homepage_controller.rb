require 'user_session'

class HomepageController < ApplicationController
  include UserSession
  before_filter :prompt_for_auth

  def index
    @repos = current_github_user.repos
  end

  def repos
    @repo_name = params[:repo_name]
    @my_handle = current_github_user.handle
    @stats = current_github_user.stats(@my_handle, @repo_name)
  end
end
