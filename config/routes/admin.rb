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