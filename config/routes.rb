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
      get 'scratchpad', to: 'scratchpad#show'
      put 'scratchpad', to: 'scratchpad#update'
      post 'scratchpad/append', to: 'scratchpad#append'
      resources :decisions do
        get :results, to: 'results#index'
        resources :participants do
          resources :approvals
        end
        resources :options do
          resources :approvals
        end
        resources :approvals
      end
      resources :notes do
        post :confirm, to: 'note#confirm'
      end
      resources :commitments do
        resources :participants
      end
      resources :cycles
      resources :users do
        resources :api_tokens, path: 'tokens'
      end
    end
  end
  # Defines the root path route ("/")
  root 'home#index'
  get 'home' => 'home#index'
  get 'settings' => 'home#settings'
  get 'admin' => 'home#admin'

  get 'cycles' => 'cycles#index'
  get 'cycles/:cycle' => 'cycles#show'

  get 'scratchpad' => 'home#scratchpad'

  get 'about' => 'home#about'
  get 'help' => 'home#help'
  get 'feedback' => 'home#feedback'

  # get 'team' => 'users#index'
  resources :users, path: 'u', param: :handle, only: [:show] do
    put 'scratchpad' => 'users#scratchpad', on: :member
    get 'settings', on: :member
    resources :api_tokens,
              path: 'settings/tokens',
              only: [:new, :create, :show, :destroy]
    post 'impersonate' => 'users#impersonate', on: :member
    delete 'impersonate' => 'users#stop_impersonating', on: :member
  end

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
