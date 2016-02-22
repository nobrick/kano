require 'sidekiq/web'

Rails.application.routes.draw do
  concern :with_account_profile do
    resource :profile, only: [ :show, :update ] do
      get :complete
    end
  end

  authenticated :user do
    root 'users/orders#index', as: :user_root
    namespace :users, as: :user, path: '/' do
      resources :orders, only: [ :new, :create, :index, :show ] do
        member do
          resource :checkout, only: [ :create, :update ]
          get :charge
          put :cancel
        end
      end
      concerns :with_account_profile
    end
  end

  authenticated :handyman do
    root 'handymen/orders#index', as: :handyman_root
    get '/handymen', to: 'handymen/orders#index'
    namespace :handymen, as: :handyman, path: '/' do
      resources :orders, only: [ :update, :index, :show ]
      resources :order_contracts, only: [ :index, :show ], path: 'contracts', as: 'contracts'
      resources :taxons, only: [ :index ]
      resources :withdrawals, only: [ :index, :new, :create ]
      concerns :with_account_profile
    end
  end

  authenticated :user, -> (u) { u.admin? } do
    namespace :admin, path: '/alpha' do
      root 'dashbord#index', as: :root
      namespace :handymen, as: :handyman do
        resources :certifications, only: [ :update, :index, :show, :new, :create ]
        resources :accounts, only: [:index, :show] do
          member do
            post :update_account_status
          end
        end

        resources :profiles, only: [:update] do
          member do
            put :update_taxons
          end
        end
      end

      namespace :users, as: :user do
        resources :accounts, only: [:index, :show] do
          member do
            post :update_account_status
          end
        end

        resources :profiles, only: [:update], shallow: true do
          resources :addresses, only: [:create, :update, :destroy]
          member do
            post :set_primary_address
          end
        end
      end

      namespace :managers, as: :manager do
        resources :accounts, only: [:index, :update, :show]
      end
      resources :orders, only: [:index, :update, :show]
    end

    mount Sidekiq::Web => '/sidekiq'
  end

  namespace :handymen do
    get 'home/index'
    get '/', to: 'home#index'
  end

  root 'home#index'
  get 'home/index'

  get 'orders/new', to: 'home#index'
  get 'contracts', to: 'handymen/home#index'

  mount ChinaCity::Engine => '/china_city'
  resource :user_wechat, only: [ :show, :create ]
  resource :handyman_wechat, only: [ :show, :create ]

  devise_for :accounts, controllers: {
    sessions: 'sessions',
    omniauth_callbacks: 'omniauth_callbacks'
  }, skip: :registrations

  [ :users, :handymen ].each { |r| devise_for r, module: r.to_s, only: :registrations }

  devise_scope :account do
    get 'getout', to: 'sessions#destroy'
  end
end
