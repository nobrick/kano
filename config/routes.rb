require 'sidekiq/web'

# Constraints class to determine scopes for users or handymen.
class ScopeRecognizer
  def initialize(scope)
    @scope = scope.to_s
  end

  def matches?(request)
    request.params[:sc] == @scope
  end
end

Rails.application.routes.draw do
  authenticated :user do
    root 'users/orders#index', as: :user_root
    namespace :users, as: :user, path: '/' do
      resources :orders, only: [ :new, :create, :index, :show ] do
        member do
          resource :checkout, only: [ :create, :update ]
          resource :resend, only: [ :update ], module: 'orders', as: 'order_resend'
          get :charge
          put :cancel
        end
      end
      resources :phone_verifications, only: [ :create ]
    end
  end

  authenticated :handyman do
    root 'handymen/orders#index', as: :handyman_root
    get '/handymen', to: 'handymen/orders#index'
    namespace :handymen, as: :handyman, path: '/' do
      resources :orders, only: [ :update, :index, :show ]
      resources :order_contracts, only: [ :index, :show ], path: 'contracts', as: 'contracts' do
        member do
          resource :resend, only: [ :update ], module: 'contracts', as: 'contract_resend'
        end
      end
      resources :taxons, only: [ :index ]
      resources :withdrawals, only: [ :index, :new, :create ]
      resource :profile, only: [ :show, :update ] do
        get :complete
      end
      resource :avatar, only: [ :edit, :update ]
    end
  end

  authenticated :user, -> (u) { u.admin? } do
    namespace :admin, path: '/alpha' do
      root 'dashboard#index', as: :root
      namespace :handymen, as: :handyman do
        resources :certifications, only: [:update, :index] do
          collection do
            match 'search' => 'certifications#search', via: :get
          end
        end
      end

      namespace :finance do
        namespace :withdrawals, as: :withdrawal do
          resources :verifications, only: [:index, :update] do
            collection do
              match 'search' => 'verifications#search', via: :get
            end
          end
          resources :transfer, only: [:index, :update] do
            collection do
              match 'search' => 'transfer#search', via: :get
            end
          end
          resources :history, only: [:index] do
            collection do
              match 'search' => 'history#search', via: :get
            end
          end
          resources :exceptions, only: [:index] do
            collection do
              match 'search' => 'exceptions#search', via: :get
            end
          end
        end
        resources :withdrawals, only: [:show]
      end

      resources :handymen, as: :handyman, shallow: true, only: [:index, :update, :show] do
        scope module: "handymen" do
          resource :profile, only: [:show, :update] do
            put :update_avatar
            put :update_taxons
          end
          resources :orders, only: [:index]

          namespace :finance do
            resources :history, only: [:index]
            resources :withdrawals, only: [:index]
            resources :exceptions, only: [:index]
          end
        end
      end

      resources :users, as: :user, shallow: true, only: [:index, :show, :update] do
        scope module: "users" do
          resources :orders, only: [:index]
          resource :profile, only: [:update, :show] do
            put :update_avatar
            post :set_primary_address
          end
          resources :addresses, only: [:create, :update, :destroy], shallow_path: "users", shallow_prefix: "user"
        end
      end

      resources :managers, as: :manager, only: [:index, :update, :show]

      resources :orders, only: [:index, :show] do
        member do
          put :cancel
        end
        collection do
          match 'search' => 'orders#search', via: :get
        end
      end
    end

    mount Sidekiq::Web => '/sidekiq'
  end

  namespace :handymen do
    get 'home/index'
    get '/', to: 'home#index'
  end

  root 'guides#index'
  get 'home/index'
  get 'home/terms'
  get 'guides/index'

  with_options constraints: ScopeRecognizer.new(:user), to: 'guides#index' do |v|
    v.get 'orders/new'
    v.get 'orders/:id'
    v.get 'alpha/orders/:id'
  end

  with_options(
    constraints: ScopeRecognizer.new(:handyman),
    to: 'handymen/home#index') do |v|

    v.get 'contracts'
    v.get 'contracts/:id'
    v.get 'profile'
    v.get 'withdrawals'
  end

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
