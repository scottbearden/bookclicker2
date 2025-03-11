Rails.application.routes.draw do
  
  require 'sidekiq/web'

  mount Sidekiq::Web => '/sidekiq'  
  
  root to: 'homepages#root'
  get '/benefits', to: 'homepages#landing'
  get '/pricing', to: 'homepages#landing'
  get '/sign_up', to: 'homepages#landing'
  
  get '/stripe/callback', to: 'stripe#callback'
  post '/stripe/charge_buyer', to: 'stripe#charge_buyer'
  post '/stripe/begin_assistant_payment_plan', to: 'stripe#begin_assistant_payment_plan'
  
  post '/stripe/external_account_deleted', 'stripe#external_account_deleted'
  post '/stripe/external_account_deauthorized', 'stripe#external_account_deauthorized'
  post '/stripe/external_account_updated', 'stripe#external_account_updated'
  post '/stripe/payment_intent_callback', 'stripe#payment_intent_callback'

  get 'genres', to: 'genres#index'
  
  resource :dashboard, only: [:show]
  
  resources :conversations, only: [:index, :show, :create]
  
  resources :payment_infos, only: [:index, :create, :update] do
    collection do
      get :confirmed
    end
  end

  resources :terms_of_service, only: [:new, :create] do
    post :accept, on: :collection
  end
  
  namespace :policies do 
    get '/cookies', to: 'pages#cookies_policy'
    get '/privacy', to: 'pages#privacy'
    get '/terms_of_use', to: 'pages#terms_of_use'
    get '/acceptable_use', to: 'pages#acceptable_use'
    get '/faq/', to: 'pages#faq'
  end
  
  get '/sign_in', to: redirect('/login')
  
  get '/login', to: 'sessions#new', as: :login
  post '/login', to: 'sessions#create'
  get '/sign_out', to: 'sessions#destroy', as: :sign_out
  
  get '/mailchimp/auth' => 'mailchimp_auth#index'
  get '/mailchimp/auth/callback' => 'mailchimp_auth#callback'
  
  get '/aweber/auth' => 'aweber_auth#index'
  get '/aweber/auth/callback' => 'aweber_auth#callback'
  
  get '/create_account' => 'users#new'
  put '/users/password' => 'users#update_password'
  
  get '/reset_password_request', to: 'users#reset_password_request'
  post '/reset_password_request', to: 'users#reset_password_request_submit'
  
  get '/reset_password', to: 'users#reset_password_page'
  post '/reset_password', to: 'users#reset_password_submit'
  
  get '/unverified', to: 'users#unverified'
  get '/verify_email' => 'users#verify_email'
  
  get '/assist/:auid' => 'users#assist'
  get '/user/destroy_assistant/:user_id' => 'users#destroy_assistant'
  
  resource :marketplace, only: [:show]
  resources :assistant_invites, only: [:show]
  
  get '/booking_calendar/:list_id' => 'booking_calendars#show'
  get '/swap_calendar/:reservation_id' => 'booking_calendars#swap'
  
  resource :profile, only: [:show]
  resource :integrations, only: [:show]
  resources :clients, only: [:index]
  
  resources :my_lists, only: [:index, :show, :update] do
    collection do
      get 'selections'
      put 'selections' => 'my_lists#update_selections'
    end
  end
  
  resources :pen_names, only: [:index] do
    member do
      get :request_access
      get :grant_request
      get :deny_request
    end
    collection do
      get :sharing
    end
  end
  
  resources :my_books, only: [:show, :update, :new, :create] do
    resource :launch, only: [:show]
  end
  
  resources :calendars, only: [:show]
  
  resources :reservations, only: [:create] do
    member do
      post 'swap'
      get 'accept'
      get 'decline'
      get 'info'
      get 'pay'
      get 'refund'
      post 'cancel_swap'
      post 'cancel_swap_as_buyer'
      post 'cancel_unpaid_promo'
      post 'request_cancel_and_refund'
      put 'reschedule'
    end
  end

  get '/confirm_promos', to: 'confirm_promos#select'
  get '/confirm_promos/confirmed', to: 'confirm_promos#confirmed'
  
  resources :external_reservations, only: [:create, :destroy]

  resources :one_day_inventories, only: [:create]
  
  resources :users, only: [:create]
  
  get '/assistant_requests/:users_assistant_id/accept/:id' => 'api/assistant_payment_requests#pay_and_accept' 
  
  namespace :api do

    resources :conversations, only: [:create, :show] do
      member do
        post :reply
      end
      member do
        put :move_to_trash
        put :untrash
      end
    end
    
    resources :payment_infos, only: [:destroy] do
      collection do
        get :default_source
        post :set_default_source
      end
    end

    resources :confirm_promos, only: [:create]
    get '/confirm_promos/:reservation_id/options', to: 'confirm_promos#options'
    
    resources :user_events, only: [:create]
    resource :session, only: [:create, :show, :destroy]
    resources :my_lists, only: [:index, :show, :update] do 
      member do
        put :inventories_genres_prices
        put :cutoff_date
      end
    end
    
    resources :pen_names do 
      collection do
        get :list_for_buyer
      end
    end
    
    resources :my_books do
      member do 
        get :launch_data
      end
    end
    
    resources :one_day_inventories, only: [:index, :create]
    resources :lists, only: [:index] do
      resources :campaigns, only: [:index]
      member do 
        post :rate
      end
    end
    resources :integrations, only: [:index, :create, :show, :update, :destroy]
    resources :amazon_products, only: [:index] do
      collection do
        get :profile
      end
    end
    post 'calendars/availability' => 'calendars#availability'
    post 'booking_calendars/availability' => 'booking_calendars#availability'
    
    post '/images/upload' => 'images#upload'
    put '/images/upload' => 'images#upload'

    get '/users/send_verification_email' => 'users#send_verification_email'
    put '/users/auto_subscribe' => 'users#auto_subscribe'
    put '/users/email_subscribe' => 'users#email_subscribe'
    get '/user' => 'users#show'
    put '/user/basic_info' => 'users#update_basic_info'
    put '/user/country' => 'users#update_country'
    delete '/user/destroy_member' => 'users#destroy_member'
    
    resources :users_assistants do
      collection do
        post :invite
      end
      resources :assistant_payment_requests, only: [:create] do
        member do
          put :decline
          put :accept
          put :terminate
        end
      end
    end
    
    post '/user/assistant_invite' => 'users#invite_assistant'
    
    resources :list_subscriptions, only: [:update]
    
    resources :external_reservations, only: [:create, :update, :destroy]
    resources :reservations, only: [:update] do
      member do
        put :accept
        put :decline
        put :dismiss
        post :confirmation_request
        post :refund_request
        post :seller_cancel
        post :buyer_cancel
        post :seller_refund
        post :buyer_refund
      end
      collection do
        post :seller_cancel_all
        post :buyer_cancel_all
      end
    end
    
  end

end
