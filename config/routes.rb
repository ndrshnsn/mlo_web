Rails.application.routes.draw do

  require 'sidekiq/web'
  require 'sidekiq/cron/web'
  Rails.application.routes.draw do
    mount Sidekiq::Web => '/sidekiq'
  end

  get '401', to: 'application#page_unauthorized', as: :page_unauthorized
  get '404', to: 'application#page_not_found'
  get '422', to: 'application#server_error'
  get '500', to: 'application#server_error'

  # Devise Authentication
  # namespace :api, defaults: { format: :json } do
  #   devise_for :users,
  #     path: '',
  #     class_name: "ApiUser",
  #     skip: [:registrations, :invitations,
  #       :passwords, :confirmations,
  #       :unlocks],
  #     path_names: {
  #       sign_in: 'login',
  #       sign_out: 'logout',
  #       registration: 'signup'
  #     }
  #   as :user do
  #     get 'login', to: 'devise/sessions#new'
  #     get 'login.json', to: 'devise/sessions#new'
  #     delete 'logout', to: 'devise/sessions#destroy'
  #   end
  # end

  devise_for :users, defaults: {format: :html},
    # path: '',
    skip: [:sessions, :registrations, :confirmations],
    controllers: {
      registrations: "users/registrations",
      confirmations: "users/confirmations",
      passwords: "users/passwords",
      sessions: "users/sessions",
      omniauth_callbacks: "users/omniauth_callbacks"
    }

  get "not_badge", to: "notifications#badge", as: :not_badge
  post "not_badge/read_all", to: "notifications#badge_read_all", as: :not_badge_read_all
  get "notifications", to: "notifications#index", as: :notifications

  get "dt_i18n", to: "datatables#datatable_i18n"
  post "gt_brcb", to: "breadcrumbs#update"
  post "cleague/:id", to: "dashboard#change_league", as: :change_active_league

  draw(:user)
  draw(:manager)
  draw(:admin)

  root "dashboard#index", via: [:get, :post]
end
