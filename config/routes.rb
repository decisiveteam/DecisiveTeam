require 'sidekiq/web'

Rails.application.routes.draw do
  authenticate :user, lambda { |u| u.is_admin? } do
    mount Sidekiq::Web => '/sidekiq'
    # TODO Add more admin routes here
  end
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

  get '/new_team' => 'teams#new'
  resources :teams, only: [:create, :index, :show] do
    get '/new_decision' => 'decisions#new'
    resources :decisions, only: [:create, :show] do
      get '/results.html' => 'decisions#results_partial'
      get '/options.html' => 'decisions#options_partial'
    end

    get '/new_tag' => 'tags#new'
    resources :tags, only: [:create]
    get '/tags/:name' => 'tags#show'
  end
end
