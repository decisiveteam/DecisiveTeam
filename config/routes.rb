Rails.application.routes.draw do
  use_doorkeeper
  devise_for :users
  resources :oauth_applications, except: [:show]

  namespace :api do
    namespace :v1 do
      resources :teams do
        resources :webhooks, only: [:index, :create, :destroy]
        resources :decision_logs do
          resources :webhooks, only: [:index, :create, :destroy]
          resources :decisions do
            resources :webhooks, only: [:index, :create, :destroy]
            get :results, to: 'results#index'
            resources :options do
              resources :approvals
            end
          end
        end
      end
    end
  end
  # Defines the root path route ("/")
  root 'home#index'
end
