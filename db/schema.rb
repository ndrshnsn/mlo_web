# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2023_10_31_175403) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "audits", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "auditable_type"
    t.uuid "associated_id"
    t.string "associated_type"
    t.uuid "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.jsonb "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.uuid "auditable_id", default: -> { "gen_random_uuid()" }, null: false
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "awards", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.integer "prize"
    t.integer "ranking"
    t.uuid "league_id", null: false
    t.boolean "status", default: true
    t.text "trophy_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["league_id"], name: "index_awards_on_league_id"
  end

  create_table "championship_awards", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "championship_id", null: false
    t.uuid "award_id", null: false
    t.string "award_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["award_id"], name: "index_championship_awards_on_award_id"
    t.index ["championship_id"], name: "index_championship_awards_on_championship_id"
  end

  create_table "championship_positions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "championship_id", null: false
    t.uuid "club_id", null: false
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["championship_id"], name: "index_championship_positions_on_championship_id"
    t.index ["club_id"], name: "index_championship_positions_on_club_id"
  end

  create_table "championships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.uuid "season_id", null: false
    t.text "badge_data"
    t.integer "status"
    t.text "advertisement"
    t.jsonb "preferences", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["preferences"], name: "index_championships_on_preferences", using: :gin
    t.index ["season_id"], name: "index_championships_on_season_id"
  end

  create_table "club_awards", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "club_id", null: false
    t.string "source_type", null: false
    t.uuid "source_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["club_id"], name: "index_club_awards_on_club_id"
    t.index ["source_type", "source_id"], name: "index_club_awards_on_source"
  end

  create_table "club_championships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "club_id", null: false
    t.uuid "championship_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "games", default: 0
    t.integer "wins", default: 0
    t.integer "draws", default: 0
    t.integer "losses", default: 0
    t.integer "goalsfor", default: 0
    t.integer "goalsagainst", default: 0
    t.integer "goalsdiff", default: 0
    t.integer "points", default: 0
    t.integer "gamerate", default: 0
    t.integer "group"
    t.index ["championship_id"], name: "index_club_championships_on_championship_id"
    t.index ["club_id"], name: "index_club_championships_on_club_id"
  end

  create_table "club_exchanges", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "from_club_id", null: false
    t.uuid "to_club_id", null: false
    t.jsonb "from_details", default: {}
    t.jsonb "to_details", default: {}
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reason"
    t.index ["from_club_id"], name: "index_club_exchanges_on_from_club_id"
    t.index ["from_details"], name: "index_club_exchanges_on_from_details", using: :gin
    t.index ["to_club_id"], name: "index_club_exchanges_on_to_club_id"
    t.index ["to_details"], name: "index_club_exchanges_on_to_details", using: :gin
  end

  create_table "club_finances", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "club_id", null: false
    t.string "operation"
    t.integer "value"
    t.integer "balance"
    t.string "source_type"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "source_id"
    t.index ["club_id"], name: "index_club_finances_on_club_id"
  end

  create_table "club_games", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "game_id", null: false
    t.uuid "club_id", null: false
    t.uuid "player_season_id", null: false
    t.uuid "assist_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assist_id"], name: "index_club_games_on_assist_id"
    t.index ["club_id"], name: "index_club_games_on_club_id"
    t.index ["game_id"], name: "index_club_games_on_game_id"
    t.index ["player_season_id"], name: "index_club_games_on_player_season_id"
  end

  create_table "club_players", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "club_id", null: false
    t.uuid "player_season_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["club_id"], name: "index_club_players_on_club_id"
    t.index ["player_season_id"], name: "index_club_players_on_player_season_id"
  end

  create_table "clubs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "def_team_id", null: false
    t.uuid "user_season_id", null: false
    t.jsonb "details", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["def_team_id"], name: "index_clubs_on_def_team_id"
    t.index ["details"], name: "index_clubs_on_details", using: :gin
    t.index ["user_season_id"], name: "index_clubs_on_user_season_id"
  end

  create_table "def_countries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "alias"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "def_player_positions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.integer "order"
    t.string "platform", default: "null"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "def_players", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.integer "height"
    t.integer "weight"
    t.integer "age"
    t.string "foot"
    t.boolean "active", default: true
    t.string "platform"
    t.string "slug"
    t.jsonb "details", default: {}
    t.uuid "def_player_position_id", null: false
    t.uuid "def_country_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["def_country_id"], name: "index_def_players_on_def_country_id"
    t.index ["def_player_position_id"], name: "index_def_players_on_def_player_position_id"
    t.index ["details"], name: "index_def_players_on_details", using: :gin
    t.index ["platform"], name: "index_def_players_on_platform"
    t.index ["slug"], name: "index_def_players_on_slug"
  end

  create_table "def_teams", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.boolean "nation", default: false
    t.uuid "def_country_id", null: false
    t.boolean "active", default: true
    t.jsonb "details", default: {}, null: false
    t.text "platforms"
    t.text "alias"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["def_country_id"], name: "index_def_teams_on_def_country_id"
    t.index ["details"], name: "index_def_teams_on_details", using: :gin
    t.index ["slug"], name: "index_def_teams_on_slug", unique: true
  end

  create_table "game_best_players", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "club_id"
    t.uuid "player_season_id", null: false
    t.uuid "game_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["club_id"], name: "index_game_best_players_on_club_id"
    t.index ["game_id"], name: "index_game_best_players_on_game_id"
    t.index ["player_season_id"], name: "index_game_best_players_on_player_season_id"
  end

  create_table "game_cards", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "game_id", null: false
    t.uuid "player_season_id", null: false
    t.uuid "club_id", null: false
    t.boolean "ycard"
    t.boolean "rcard"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["club_id"], name: "index_game_cards_on_club_id"
    t.index ["game_id"], name: "index_game_cards_on_game_id"
    t.index ["player_season_id"], name: "index_game_cards_on_player_season_id"
  end

  create_table "games", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "championship_id", null: false
    t.uuid "home_id", null: false
    t.uuid "visitor_id", null: false
    t.integer "phase"
    t.integer "hscore"
    t.integer "vscore"
    t.integer "phscore"
    t.integer "pvscore"
    t.integer "status"
    t.boolean "hsaccepted", default: false
    t.boolean "vsaccepted", default: false
    t.boolean "hfaccepted", default: false
    t.boolean "vfaccepted", default: false
    t.uuid "eresults_id"
    t.boolean "mresult", default: false
    t.text "mdescription"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "gsequence"
    t.integer "subtype", default: 0
    t.index ["championship_id"], name: "index_games_on_championship_id"
    t.index ["eresults_id"], name: "index_games_on_eresults_id"
    t.index ["home_id"], name: "index_games_on_home_id"
    t.index ["visitor_id"], name: "index_games_on_visitor_id"
  end

  create_table "global_notifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "league_id", null: false
    t.string "title"
    t.text "body"
    t.jsonb "params"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["league_id"], name: "index_global_notifications_on_league_id"
    t.index ["params"], name: "index_global_notifications_on_params", using: :gin
  end

  create_table "identities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "provider"
    t.string "uid"
    t.uuid "user_id"
    t.string "gravatar_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_identities_on_user_id"
  end

  create_table "leagues", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.uuid "user_id", null: false
    t.boolean "status"
    t.string "slug"
    t.string "platform"
    t.text "badge_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "slots", default: 0
    t.index ["user_id"], name: "index_leagues_on_user_id"
  end

  create_table "notifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "recipient_type", null: false
    t.uuid "recipient_id", null: false
    t.string "type", null: false
    t.jsonb "params"
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["read_at"], name: "index_notifications_on_read_at"
    t.index ["recipient_type", "recipient_id"], name: "index_notifications_on_recipient"
  end

  create_table "player_season_finances", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "player_season_id", null: false
    t.string "operation"
    t.integer "value"
    t.uuid "source_id"
    t.string "source_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player_season_id"], name: "index_player_season_finances_on_player_season_id"
  end

  create_table "player_seasons", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "def_player_id", null: false
    t.uuid "season_id", null: false
    t.jsonb "details", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["def_player_id"], name: "index_player_seasons_on_def_player_id"
    t.index ["details"], name: "index_player_seasons_on_details", using: :gin
    t.index ["season_id"], name: "index_player_seasons_on_season_id"
  end

  create_table "player_transactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "player_season_id", null: false
    t.uuid "from_club_id"
    t.uuid "to_club_id"
    t.string "transfer_mode"
    t.integer "transfer_rate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["from_club_id"], name: "index_player_transactions_on_from_club_id"
    t.index ["player_season_id"], name: "index_player_transactions_on_player_season_id"
    t.index ["to_club_id"], name: "index_player_transactions_on_to_club_id"
  end

  create_table "rankings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "season_id", null: false
    t.uuid "club_id", null: false
    t.integer "points"
    t.string "operation"
    t.uuid "source_id"
    t.string "source_type"
    t.text "description"
    t.integer "balance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["club_id"], name: "index_rankings_on_club_id"
    t.index ["season_id"], name: "index_rankings_on_season_id"
  end

  create_table "season_awards", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "season_id", null: false
    t.uuid "award_id", null: false
    t.string "award_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["award_id"], name: "index_season_awards_on_award_id"
    t.index ["season_id"], name: "index_season_awards_on_season_id"
  end

  create_table "seasons", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.uuid "league_id", null: false
    t.jsonb "preferences", default: {}
    t.integer "status", default: 0
    t.text "advertisement"
    t.date "start"
    t.integer "duration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["league_id"], name: "index_seasons_on_league_id"
    t.index ["preferences"], name: "index_seasons_on_preferences", using: :gin
  end

  create_table "settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "var", null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["var"], name: "index_settings_on_var", unique: true
  end

  create_table "user_acls", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "role"
    t.boolean "permitted"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "league_id", null: false
    t.string "extra"
    t.index ["league_id"], name: "index_user_acls_on_league_id"
    t.index ["role"], name: "index_user_acls_on_role"
    t.index ["user_id"], name: "index_user_acls_on_user_id"
  end

  create_table "user_leagues", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "league_id", null: false
    t.boolean "status", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["league_id"], name: "index_user_leagues_on_league_id"
    t.index ["user_id"], name: "index_user_leagues_on_user_id"
  end

  create_table "user_seasons", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "season_id", null: false
    t.jsonb "preferences", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["preferences"], name: "index_user_seasons_on_preferences", using: :gin
    t.index ["season_id"], name: "index_user_seasons_on_season_id"
    t.index ["user_id"], name: "index_user_seasons_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.integer "role"
    t.string "slug"
    t.string "full_name"
    t.boolean "active", default: true
    t.string "nickname"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "jti", null: false
    t.string "platform"
    t.string "phone"
    t.date "birth"
    t.text "avatar_data"
    t.jsonb "preferences", default: {}, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["preferences"], name: "index_users_on_preferences", using: :gin
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["slug"], name: "index_users_on_slug", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "web_push_devices", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "endpoint"
    t.string "auth_key"
    t.string "p256dh_key"
    t.string "user_agent"
    t.cidr "user_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_web_push_devices_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "awards", "leagues"
  add_foreign_key "championship_awards", "awards"
  add_foreign_key "championship_awards", "championships"
  add_foreign_key "championship_positions", "championships"
  add_foreign_key "championship_positions", "clubs"
  add_foreign_key "championships", "seasons"
  add_foreign_key "club_awards", "clubs"
  add_foreign_key "club_championships", "championships"
  add_foreign_key "club_championships", "clubs"
  add_foreign_key "club_exchanges", "clubs", column: "from_club_id"
  add_foreign_key "club_exchanges", "clubs", column: "to_club_id"
  add_foreign_key "club_finances", "clubs"
  add_foreign_key "club_games", "clubs"
  add_foreign_key "club_games", "games"
  add_foreign_key "club_games", "player_seasons"
  add_foreign_key "club_games", "player_seasons", column: "assist_id"
  add_foreign_key "club_players", "clubs"
  add_foreign_key "club_players", "player_seasons"
  add_foreign_key "clubs", "def_teams"
  add_foreign_key "clubs", "user_seasons"
  add_foreign_key "def_players", "def_countries"
  add_foreign_key "def_players", "def_player_positions"
  add_foreign_key "def_teams", "def_countries"
  add_foreign_key "game_best_players", "clubs"
  add_foreign_key "game_best_players", "games"
  add_foreign_key "game_best_players", "player_seasons"
  add_foreign_key "game_cards", "clubs"
  add_foreign_key "game_cards", "games"
  add_foreign_key "game_cards", "player_seasons"
  add_foreign_key "games", "championships"
  add_foreign_key "games", "clubs", column: "eresults_id"
  add_foreign_key "games", "clubs", column: "home_id"
  add_foreign_key "games", "clubs", column: "visitor_id"
  add_foreign_key "global_notifications", "leagues"
  add_foreign_key "identities", "users"
  add_foreign_key "leagues", "users"
  add_foreign_key "player_season_finances", "player_seasons"
  add_foreign_key "player_seasons", "def_players"
  add_foreign_key "player_seasons", "seasons"
  add_foreign_key "player_transactions", "clubs", column: "from_club_id"
  add_foreign_key "player_transactions", "clubs", column: "to_club_id"
  add_foreign_key "player_transactions", "player_seasons"
  add_foreign_key "rankings", "clubs"
  add_foreign_key "rankings", "seasons"
  add_foreign_key "season_awards", "awards"
  add_foreign_key "season_awards", "seasons"
  add_foreign_key "seasons", "leagues"
  add_foreign_key "user_acls", "leagues"
  add_foreign_key "user_acls", "users"
  add_foreign_key "user_leagues", "leagues"
  add_foreign_key "user_leagues", "users"
  add_foreign_key "user_seasons", "seasons"
  add_foreign_key "user_seasons", "users"
  add_foreign_key "web_push_devices", "users"
end
