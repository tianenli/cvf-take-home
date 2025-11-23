require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # Mount Sidekiq web UI
  mount Sidekiq::Web => '/sidekiq'

  # API routes
  namespace :api do
    namespace :v1 do
      resources :organizations, only: [:index, :show] do
        resources :cohorts, only: [:index, :show, :update] do
          member do
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
