Rails.application.routes.draw do
  get 'login' => 'sessions#new'
  get 'auth/:provider/callback' => 'sessions#oauth_callback'
  get 'login/return' => 'sessions#return'
  get 'login/callback' => 'sessions#internal_callback'
  delete '/logout' => 'sessions#destroy'
  get 'logout-success' => 'sessions#logout_success'

  namespace :api do
    namespace :v1 do
      get '/', to: 'info#index'
      if ENV['APPS_ENABLED'].include?('decisive')
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
      if ENV['APPS_ENABLED'].include?('coordinated')
        # TODO
      end
    end
  end
  # Defines the root path route ("/")
  root 'home#index'
  get 'settings' => 'home#settings'
  get 'admin' => 'home#admin'
  # get 'team' => 'users#index'
  get 'u/:handle' => 'users#show'
  get 'cycles' => 'cycles#index'
  get 'cycles/:cycle' => 'cycles#show'

  get 'note' => 'notes#new'
  resources :notes, only: [:create, :show], path: 'n' do
    get '/history.html' => 'notes#history_log_partial'
    post '/confirm.html' => 'notes#confirm_and_return_partial'
    put '/edit_display_name.html' => 'notes#edit_display_name_and_return_partial'
  end

  get '/decide' => 'decisions#new'
  resources :decisions, only: [:create, :show], path: 'd' do
    get '/results.html' => 'decisions#results_partial'
    get '/options.html' => 'decisions#options_partial'
    post '/options.html' => 'decisions#create_option_and_return_options_partial'
  end

  get 'commit' => 'commitments#new'
  resources :commitments, only: [:create, :show], path: 'c' do
    get '/status.html' => 'commitments#status_partial'
    get '/participants.html' => 'commitments#participants_list_items_partial'
    post '/join.html' => 'commitments#join_and_return_partial'
    put '/edit_display_name.html' => 'commitments#edit_display_name_and_return_partial'
  end
end
