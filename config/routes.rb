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
      resources :notes do
        post :confirm, to: 'note#confirm'
      end
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
      resources :commitments do
        resources :participants
      end
      resources :cycles
      resources :users do
        resources :api_tokens, path: 'tokens'
      end
      # resources :webhooks
      get 'custom/data', to: 'custom_data#info'
      get 'custom/config', to: 'custom_data#configuration'
      get 'custom/data/:table_name/:id/history', to: 'custom_data#history'
      resources :custom_data, path: 'custom/data/:parent_table_name/:parent_id/:table_name' do
        get 'history', to: 'custom_data#history'
      end
      resources :custom_data, path: 'custom/data/:table_name'
    end
  end
  # Defines the root path route ("/")
  root 'home#index'
  get 'home' => 'home#index'
  get 'settings' => 'home#settings'
  get 'admin' => 'home#admin'

  get 'scratchpad' => 'home#scratchpad'

  get 'about' => 'home#about'
  get 'help' => 'home#help'
  get 'feedback' => 'home#feedback'

  resources :users, path: 'u', param: :handle, only: [:show] do
    put 'scratchpad' => 'users#scratchpad', on: :member
    get 'settings', on: :member
    resources :api_tokens,
              path: 'settings/tokens',
              only: [:new, :create, :show, :destroy]
    post 'impersonate' => 'users#impersonate', on: :member
    delete 'impersonate' => 'users#stop_impersonating', on: :member
  end

  get 'studios' => 'studios#index'
  get 'studios/new' => 'studios#new'
  get 'studios/available' => 'studios#handle_available'
  post 'studios' => 'studios#create'
  get 's/:studio_handle' => 'studios#show'
  get "s/:studio_handle/cycles" => 'cycles#index'
  get "s/:studio_handle/cycles/:cycle" => 'cycles#show'
  get "s/:studio_handle/team" => 'studios#team'
  get "s/:studio_handle/settings" => 'studios#settings'
  post "s/:studio_handle/settings" => 'studios#update_settings'
  get "s/:studio_handle/invite" => 'studios#invite'
  get "s/:studio_handle/join" => 'studios#join'
  post "s/:studio_handle/join" => 'studios#accept_invite'
  ['', 's/:studio_handle'].each do |prefix|
    get "#{prefix}/note" => 'notes#new'
    post "#{prefix}/note" => 'notes#create'
    resources :notes, only: [:show], path: "#{prefix}/n" do
      get '/edit' => 'notes#edit'
      post '/edit' => 'notes#update'
      get '/history.html' => 'notes#history_log_partial'
      post '/confirm.html' => 'notes#confirm_and_return_partial'
      put '/edit_display_name.html' => 'notes#edit_display_name_and_return_partial'
      put '/pin' => 'notes#pin'
    end

    get "#{prefix}/decide" => 'decisions#new'
    post "#{prefix}/decide" => 'decisions#create'
    resources :decisions, only: [:show], path: "#{prefix}/d" do
      get '/results.html' => 'decisions#results_partial'
      get '/options.html' => 'decisions#options_partial'
      post '/options.html' => 'decisions#create_option_and_return_options_partial'
      put '/pin' => 'decisions#pin'
    end

    get "#{prefix}/commit" => 'commitments#new'
    post "#{prefix}/commit" => 'commitments#create'
    resources :commitments, only: [:show], path: "#{prefix}/c" do
      get '/status.html' => 'commitments#status_partial'
      get '/participants.html' => 'commitments#participants_list_items_partial'
      post '/join.html' => 'commitments#join_and_return_partial'
      put '/edit_display_name.html' => 'commitments#edit_display_name_and_return_partial'
      put '/pin' => 'commitments#pin'
    end

    namespace :api, path: "#{prefix}/api" do
      namespace :v1 do
        get '/', to: 'info#index'
        resources :notes do
          post :confirm, to: 'note#confirm'
        end
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
        resources :commitments do
          resources :participants
        end
        resources :cycles
        # resources :webhooks
        get 'custom/data', to: 'custom_data#info'
        get 'custom/config', to: 'custom_data#configuration'
        get 'custom/data/:table_name/:id/history', to: 'custom_data#history'
        resources :custom_data, path: 'custom/data/:parent_table_name/:parent_id/:table_name' do
          get 'history', to: 'custom_data#history'
        end
        resources :custom_data, path: 'custom/data/:table_name'
      end
    end
  end
end
