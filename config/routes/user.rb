as :user do
  ## Session
  get "login", to: "users/sessions#new", as: :new_user_session
  post "login", to: "users/sessions#create", as: :user_session
  delete "logout", to: "users/sessions#destroy", as: :destroy_user_session

  get "active", to: "users/sessions#active"
  get "timeout", to: "users/sessions#timeout"

  ## Password
  get "recover", to: "users/passwords#edit"
  get "forgot", to: "users/passwords#new"
  match "password/update", to: "users/passwords#update", via: [:patch, :put]
  post "password/create", to: "users/passwords#create", as: :password_create

  ## Registration
  get "register", to: "users/registrations#new"
  post "register/create", to: "users/registrations#create"
  get "profile/cancel", to: "users/registrations#cancel"
  delete "profile/destroy", to: "users/registrations#destroy"

  ## Profile
  get "profile/password", to: "profile#pw", as: :profile_password
  patch "profile/password/:id", to: "profile#update_pw", as: :profile_update_pw
  get "profile", to: "profile#index"
  patch "profile/update/:id", to: "profile#update", as: :profile_update
  get "profile/system", to: "profile#system", as: :profile_system
  patch "profile/update_system/:id", to: "profile#update_system", as: :profile_update_system
  get "profile/social", to: "profile#social", as: :profile_social
  patch "profile/social/disconnect/:provider", to: "profile#social_disconnect", as: :profile_social_disconnect

  post "notifications/subscribe", to: "profile#subscribe", as: :notifications_subscribe
  post "notifications/unsubscribe", to: "profile#unsubscribe", as: :notifications_unsubscribe

  ## Change App Language
  post "locale", to: "profile#setLocale", as: :profile_set_locale

  ## Confirmation
  get "activate", to: "users/confirmations#show", as: :user_confirmation
  post "activate", to: "users/confirmations#create", as: nil
  get "activate/resend", to: "users/confirmations#new", as: :new_user_confirmation


  match "user/cities", controller: "users/registrations", action: "update_cities", via: :post, as: :user_cities_registration

  ## Check for Mail Dups
  match "user/check_email", controller: "users/registrations", action: "check_email", via: :post, as: :user_check_email

  ## Check for Current Pw
  match "user/check_current_password", controller: "users/registrations", action: "check_current_password", via: :post, as: :user_check_current_password

  ## FirstSteps
  get "firststeps", to: "firststeps#index"
  match "firststeps/request", controller: "firststeps", action: "request_league", via: [:get, :post], as: :request_league
  get "firststeps/join", controller: "firststeps#join", as: :join
  post "firststeps/join_league", controller: "firsteps#join_league", as: :join_league
  post "firststeps/get_proc_dt", to: "firststeps#get_proc_dt"
  post "firststeps/check_lname", to: "firststeps#check_lname", as: :request_league_check_lname

  ## Club Management
  get "myclub/management", to: "myclub/management#index"
  match "myclub/management/get_cteams", controller: "myclub/management", action: "get_cteams", via: :post, as: :myclub_management_get_cteams
  match "myclub/management/show_team_details", controller: "myclub/management", action: "show_team_details", via: :post, as: :myclub_management_show_team_details
  match "myclub/management/select_club", controller: "myclub/management", action: "select_club", via: [:post, :patch], as: :myclub_management_select_club

  get "seasons", to: "seasons#index"
  
end