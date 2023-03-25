Rails.application.routes.draw do
  use_doorkeeper
  devise_for :users
  resources :oauth_applications, except: [:show]

  namespace :api do
    namespace :v1 do
      resources :decisions
    end
  end
  # Defines the root path route ("/")
  root 'home#index'
end
