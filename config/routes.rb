Rails.application.routes.draw do
  get '/auth/auth0/callback' => 'auth0#callback'
  get '/auth/failure' => 'auth0#failure'
  get '/auth/logout' => 'auth0#logout'
  get '/auth/redirect' => 'auth0#redirect'
  # get '/login' => 'auth0#login'
  # get '/signup' => 'auth0#signup'

  namespace :api do
    namespace :v1 do
      get '/', to: 'info#index'
      resources :decisions do
        get :results, to: 'results#index'
        resources :participants do
          resources :approvals
        end
        resources :options do
          resources :approvals
        end
      end
    end
  end
  # Defines the root path route ("/")
  root 'home#index'

  get '/decide' => 'decisions#new'
  get '/decision/:id' => 'decisions#show'
  resources :decisions, only: [:create, :show] do
    get '/results.html' => 'decisions#results_partial'
    get '/options.html' => 'decisions#options_partial'
    post '/options.html' => 'decisions#create_option_and_return_options_partial'
  end
end
