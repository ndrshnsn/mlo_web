Rails.application.routes.draw do
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

  resources :notifications, only: [:index]
  get "dt_i18n", to: "datatables#datatable_i18n"
  post "gt_brcb", to: "breadcrumbs#update"
  post "cleague/:id", to: "dashboard#change_league", as: :change_active_league

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
    post "profile/notifications/subscribe", to: "profile#subscribe", as: :profile_subscribe
    post "profile/notifications/unsubscribe", to: "profile#unsubscribe", as: :profile_unsubscribe
    get "profile/social", to: "profile#social", as: :profile_social
    patch "profile/social/disconnect/:provider", to: "profile#social_disconnect", as: :profile_social_disconnect

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
  end

  ##
  # MANAGER NAMESPACE
  namespace :manager do
    ## Users
    get "users", to: "users#index", as: :users
    get "users/waiting", to: "users#waiting", as: :users_waiting
    get "users/:id", to: "users#show", as: :user_show
    get "users/:id/acl", to: "users#acl", as: :user_acl
    match "users/:id/acl", to: "users#acl_save", via: [:post, :patch], as: :user_acl_save
    get "users/enable/:id", to: "users#enable", as: :enable_user
    get "users/disable/:id", to: "users#disable", as: :disable_user
    post "users/get_aproc_dt", to: "users#get_aproc_dt"
    post "users/get_wproc_dt", to: "users#get_wproc_dt"
    post "users/toggle/:id", to: "users#toggle", as: :user_toggle
    patch "users/eseason/:id/enable", to: "users#eseason_enable", as: :user_eseason_enable
    delete "users/destroy/:id", to: "users#destroy", as: :user_remove
    get "users/eseason/:id", to: "users#eseason", as: :user_eseason

    match "players", controller: "players", action: "index", via: :get, as: :players

    match "settings", controller: "settings", action: "index", via: :get, as: :settings
    patch "settings/update/:id", to: "settings#update", as: :settings_update

    ## Seasons
    get "seasons", to: "seasons#index", as: :seasons
    match "seasons/:id/details", controller: "seasons", action: "details", via: :get, as: :season_details
    get "seasons/new", to: "seasons#new", as: :season_new
    get "seasons/check_season_name", to: "seasons#check_season_name", as: :check_season_name
    post "seasons/create", to: "seasons#create", as: :season_create
    patch "seasons/:id/update", to: "seasons#update", as: :season_update
    get "seasons/:id/settings", to: "seasons#settings", as: :season_settings
    delete "seasons/destroy/:id", to: "seasons#destroy", as: :season_destroy
    get "seasons/new/ftax/:type", to: "seasons#ftax", as: :seasons_ftax
    get "seasons/new/pearnings/:type", to: "seasons#pearnings", as: :seasons_pearnings
    get "seasons/:id/users", to: "seasons#users", as: :season_users
    get "seasons/:id/:user/players", to: "seasons#user_players", as: :season_user_players
    post "seasons/users/get_susers_dt", to: "seasons#get_susers_dt", as: :get_susers_dt
    post "seasons/users/players/get_splayers_dt", to: "seasons#get_splayers_dt", as: :get_splayers_dt

    # match 'seasons/users/:id/:user/:player/dismiss', controller: 'seasons', action: 'user_player_dismiss', via: :post, as: :season_user_dismiss_player
    # match 'seasons/enqueue/:id', controller: 'seasons', action: 'enqueue', via: :get, as: :season_enqueue
    # match 'seasons/get_fire_tax', controller: 'seasons', action: 'get_fire_tax', via: :get, as: :season_get_fire_tax
    post "seasons/get_available_players", to: "seasons#get_available_players", as: :season_get_available_players
    match "seasons/get_cteams/:id/:user", controller: "seasons", action: "get_cteams", via: :post, as: :season_get_cteams
    match "seasons/select_club", controller: "seasons", action: "select_club", via: :post, as: :season_select_club
    match "seasons/start/:id", controller: "seasons", action: "start_season", via: :post, as: :season_start
    get "seasons/end/:id", to: "seasons#end_season", as: :season_end
    match "seasons/start_clubs_choosing/:id", controller: "seasons", action: "start_clubs_choosing", via: :post, as: :season_start_clubs_choosing
    match "seasons/stop_clubs_choosing/:id", controller: "seasons", action: "stop_clubs_choosing", via: :post, as: :season_stop_clubs_choosing
    post "seasons/start_players_raffle/:id", to: "seasons#players_raffle", via: :post, as: :season_start_players_raffle
    match "seasons/start_change_wage/:id", controller: "seasons", action: "start_change_wage", via: :post, as: :season_start_change_wage
    match "seasons/stop_change_wage/:id", controller: "seasons", action: "stop_change_wage", via: :post, as: :season_stop_change_wage
    match "seasons/start_transfer_window/:id", controller: "seasons", action: "start_transfer_window", via: :post, as: :season_start_transfer_window
    match "seasons/stop_transfer_window/:id", controller: "seasons", action: "stop_transfer_window", via: :post, as: :season_stop_transfer_window
    match "seasons/start_players_steal/:id", controller: "seasons", action: "start_players_steal", via: :post, as: :season_start_players_steal

    ## Awards
    get "awards", controller: "awards", action: "index", as: :awards
    get "awards/get_proc_dt", to: "awards#get_proc_dt"
    get "awards/edit/:id", to: "awards#edit", as: :award_edit
    patch "awards/update/:id", to: "awards#update", as: :award_update
    post "awards/get_proc_dt", to: "awards#get_proc_dt"
    get "awards/new", to: "awards#new", as: :award_new
    post "awards/create", to: "awards#create", as: :award_create
    delete "awards/destroy/:id", to: "awards#destroy", as: :award_destroy

    ## Championships
    get "championships", to: "championships#index", as: :championships
    get "championships/new", to: "championships#new", as: :championship_new
    get "championships/check_championship_name", to: "championships#check_championship_name", as: :check_championship_name
    get "championships/get_ctype_partial/:ctype", to: "championships#get_ctype_partial", as: :championships_ctype_partial
    get "championships/:id/details", to: "championships#details", as: :championship_details
    post "championships/create", to: "championships#create", as: :championship_create
    get "championships/:id/:caction", to: "championships#cactions", as: :championship_caction
    patch "championships/:id/define_clubs", to: "championships#define_clubs", as: :championship_define_clubs
    get "championships/get_ctype_options", to: "championships#get_ctype_options"

    match "championships/:id/settings", controller: "championships", action: "settings", via: :post, as: :championship_settings
    match "championships/games/:id", to: "championships#games", via: :post, as: :championship_games
    get "championships/games/:id/games_proc_dt", to: "championships#games_proc_dt", as: :championship_games_proc_dt
    delete "championships/destroy/:id", to: "championships#destroy", as: :championship_destroy
    match "championships/update/:id", controller: "championships", action: "update", via: :post, as: :championships_update
    match "championships/:id/game/:game/:iteration/contest/:gaction", controller: "championships", action: "game_contest", via: [:get, :post], as: :championship_game_contest
    match "championships/:id/game/:game/:iteration/applywo", controller: "championships", action: "applywo", via: :get, as: :championship_game_applywo
  end

  ##
  # ADMIN NAMESPACE
  namespace :admin do
    get "insights/audits", to: "insights/insights_audits#index"
    post "insights/audits/get_proc_dt", to: "insights/insights_audits#get_proc_dt"
    get "insights/audits/details/:id", to: "insights/insights_audits#details", as: :insights_audit_detail

    get "playerdb/countries", to: "playerdb/playerdb_countries#index"
    get "playerdb/countries/new", to: "playerdb/playerdb_countries#new"
    get "playerdb/countries/edit/:id", to: "playerdb/playerdb_countries#edit", as: :playerdb_countries_edit
    post "playerdb/countries/check_name", to: "playerdb/playerdb_countries#check_name", as: :playerdb_countries_check_name
    post "playerdb/countries/create", to: "playerdb/playerdb_countries#create"
    patch "playerdb/countries/update/:id", to: "playerdb/playerdb_countries#update", as: :playerdb_countries_update
    delete "playerdb/countries/destroy/:id", to: "playerdb/playerdb_countries#destroy", as: :playerdb_countries_destroy
    post "playerdb/countries/get_proc_dt", to: "playerdb/playerdb_countries#get_proc_dt"

    get "playerdb/teams", to: "playerdb/playerdb_teams#index"
    post "playerdb/teams/get_proc_dt", to: "playerdb/playerdb_teams#get_proc_dt"
    post "playerdb/teams/check_lname", to: "playerdb/playerdb_teams#check_lname", as: :playerdb_team_check_lname
    get "playerdb/teams/new", to: "playerdb/playerdb_teams#new"
    get "playerdb/teams/edit/:id", to: "playerdb/playerdb_teams#edit", as: :playerdb_team_edit
    post "playerdb/teams/create", to: "playerdb/playerdb_teams#create", as: :playerdb_teams_create
    patch "playerdb/teams/update/:id", to: "playerdb/playerdb_teams#update", as: :playerdb_teams_update
    delete "playerdb/teams/destroy/:id", to: "playerdb/playerdb_teams#destroy", as: :playerdb_team_destroy
    get "playerdb/teams/details/:id", to: "playerdb/playerdb_teams#details", as: :playerdb_team_details

    get "playerdb/players", to: "playerdb/playerdb_players#index"
    post "playerdb/players/get_proc_dt", to: "playerdb/playerdb_players#get_proc_dt"
    get "playerdb/players/:id", to: "playerdb/playerdb_players#details", as: :playerdb_player_details
    post "playerdb/players/toggle/:id", to: "playerdb/playerdb_players#toggle", as: :playerdb_player_toggle

    get "settings", to: "settings#index", as: :settings
    post "settings/update", to: "settings#update"

    get "leagues", to: "leagues#index"
    post "leagues/get_proc_dt", to: "leagues#get_proc_dt"
    get "leagues/get_proc_ldt", to: "leagues#get_proc_ldt"
    get "leagues/new", to: "leagues#new", as: :league_new
    post "leagues/create", to: "leagues#create", as: :league_create
    get "leagues/check_lname", to: "leagues#check_lname", as: :league_check_lname
    delete "leagues/destroy/:id", to: "leagues#destroy", as: :league_destroy
    get "leagues/edit/:id", to: "leagues#edit", as: :league_edit
    patch "leagues/update/:id", to: "leagues#update", as: :league_update

    get "accounts", to: "accounts#index"
    post "accounts/get_proc_dt", to: "accounts#get_proc_dt"
    get "accounts/edit/:id", to: "accounts#edit", as: :account_edit
    delete "accounts/destroy/:id", to: "accounts#destroy", as: :account_destroy
    patch "accounts/update/:id", to: "accounts#update", as: :account_update
    get "accounts/status/:id", to: "accounts#toggle", as: :account_toggle
  end

  root "dashboard#index", via: [:get, :post]
end
