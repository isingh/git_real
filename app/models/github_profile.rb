class GithubProfile < ActiveRecord::Base
  validates :handle, :oauth_token, presence: true
  validates :handle, uniqueness: true
end

