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

  get "settings", to: "settings#index", as: :settings
  patch "settings/update/:id", to: "settings#update", as: :settings_update

  ## Seasons
  get "seasons", to: "seasons#index", as: :seasons
  match "seasons/details/:id", controller: "seasons", action: "details", via: :get, as: :season_details
  get "seasons/new", to: "seasons#new", as: :season_new
  get "seasons/check_season_name", to: "seasons#check_season_name", as: :check_season_name
  post "seasons/create", to: "seasons#create", as: :season_create
  patch "seasons/update/:id", to: "seasons#update", as: :season_update
  get "seasons/settings/:id", to: "seasons#settings", as: :season_settings
  delete "seasons/destroy/:id", to: "seasons#destroy", as: :season_destroy
  get "seasons/new/ftax/:type", to: "seasons#ftax", as: :seasons_ftax
  get "seasons/new/pearnings/:type", to: "seasons#pearnings", as: :seasons_pearnings
  get "seasons/users/:id", to: "seasons#users", as: :season_users
  post "seasons/users/get_susers_dt", to: "seasons#get_susers_dt", as: :get_susers_dt
  post "seasons/users/players/get_splayers_dt", to: "seasons#get_splayers_dt", as: :get_splayers_dt
  get "seasons/players/:id/:user", to: "seasons#user_players", as: :season_user_players
  post "seasons/get_available_players", to: "seasons#get_available_players", as: :season_get_available_players

  post "seasons/actions/:id/:step", to: "seasons#steps", as: :season_steps

  # match 'seasons/users/:id/:user/:player/dismiss', controller: 'seasons', action: 'user_player_dismiss', via: :post, as: :season_user_dismiss_player
  # match 'seasons/enqueue/:id', controller: 'seasons', action: 'enqueue', via: :get, as: :season_enqueue
  # match 'seasons/get_fire_tax', controller: 'seasons', action: 'get_fire_tax', via: :get, as: :season_get_fire_tax




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