Rails.application.routes.draw do
  get '/auth/auth0/callback' => 'auth0#callback'
  get '/auth/failure' => 'auth0#failure'
  get '/auth/logout' => 'auth0#logout'
  get '/auth/redirect' => 'auth0#redirect'
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
  ['decisions', 'd'].each do |path_prefix|
    resources :decisions, only: [:create, :show], path: path_prefix do
      get '/results.html' => 'decisions#results_partial'
      get '/options.html' => 'decisions#options_partial'
      post '/options.html' => 'decisions#create_option_and_return_options_partial'
    end
  end

  get 'coordinate' => 'commitments#new'
  ['c'].each do |path_prefix|
    resources :commitments, only: [:create, :show], path: path_prefix do
      get '/status.html' => 'commitments#status_partial'
      get '/participants.html' => 'commitments#participants_list_items_partial'
      post '/join.html' => 'commitments#join_and_return_partial'
    end
  end
end
