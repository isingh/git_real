GitReal::Application.routes.draw do
  get 'auth',             to: 'users#auth'
  get 'oauth/github',     to: 'users#handle_auth'
  get 'login',            to: 'users#login'
  get 'logout',           to: 'users#logout'

  # Repos
  get 'repos/:repo_name', to: 'homepage#repos', as: 'repo_show'

  root to: 'homepage#index'
end
