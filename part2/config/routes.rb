require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :dashboard_users, skip: :all
  ActiveAdmin.routes(self)

  # Mount Sidekiq web UI
  mount Sidekiq::Web => '/sidekiq'

  # API routes
  namespace :api do
    namespace :v1 do
      # Authentication
      post 'login', to: 'sessions#create'
      delete 'logout', to: 'sessions#destroy'
      get 'me', to: 'sessions#current'

      resources :organizations, only: [:index, :show] do
        resources :cohorts, only: [:index, :show, :create, :update] do
          member do
            post :submit
            post :approve
            post :complete
            post :terminate
          end
          resources :cohort_payments, only: [:index, :show]
        end
        resources :txns, only: [:index, :create]
      end

      resources :funds, only: [:index, :show]
      resources :fund_organizations, only: [:index, :show, :update]
    end
  end

  # Health check
  get '/health', to: proc { [200, {}, ['OK']] }

  # Root path
  root to: 'admin/dashboard#index'
end
