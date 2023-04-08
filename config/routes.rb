Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  use_doorkeeper
  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    sign_up: 'signup'
  }

  namespace :api do
    namespace :v1 do
      resources :teams do
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
  # Defines the root path route ("/")
  root 'home#index'
  get '/teams' => 'home#teams'
  get '/teams/:team_id' => 'home#team'
  get '/teams/:team_id/decisions/:decision_id' => 'home#decision'
  get '/teams/:team_id/decisions/:decision_id/results' => 'home#decision_results'

  if Rails.env.development?
    namespace :dev do
      resources :decisions
    end
  end
end
