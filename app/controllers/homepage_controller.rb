require 'user_session'

class HomepageController < ApplicationController
  include UserSession
  before_filter :prompt_for_auth

  def index
    @repos = current_github_user.repos
  end

  def repos
    @repo_name = params[:repo_name]
    @prs = current_github_user.pull_requests(current_github_user.handle, @repo_name)
  end
end
