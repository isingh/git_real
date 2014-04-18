require 'user_session'

class HomepageController < ApplicationController
  include UserSession
  before_filter :prompt_for_auth

  def index
  end
end
