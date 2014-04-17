GitReal::Application.routes.draw do
  get 'auth',         to: 'users#auth'
  get 'oauth/github', to: 'users#handle_auth'
end
