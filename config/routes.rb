Rails.application.routes.draw do
  use_doorkeeper
  devise_for :users
  resources :oauth_applications, except: [:show]

  namespace :api do
    namespace :v1 do
      resources :teams do
        resources :decision_logs do
          resources :decisions do
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
