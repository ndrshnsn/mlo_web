# RailsSettings Model
class AppConfig < RailsSettings::Base
  cache_prefix { "v1" }

  ## Email Settings
  field :mail_admin, default: nil, type: :string, readonly: false
  field :mail_username, default: nil, type: :string, readonly: false
  field :mail_password, default: nil, type: :string, readonly: false

  ## Generic Player
  field :generic_player, type: :integer
  field :platforms, type: :string
  field :fake_account_password, type: :string

  ## Championship Defaults
  field :championship_minimum_players, type: :integer
  field :championship_cards_suspension_ycard, type: :integer
  field :championship_cards_suspension_rcard, type: :integer
  field :match_winning_earning, type: :integer
  field :match_draw_earning, type: :integer
  field :match_lost_earning, type: :integer
  field :match_goal_earning, type: :integer
  field :match_goal_loss, type: :integer
  field :match_yellow_card_loss, type: :integer
  field :match_red_card_loss, type: :integer
  field :match_winning_ranking, type: :integer
  field :match_draw_ranking, type: :integer
  field :match_lost_ranking, type: :integer
  field :match_winning_points, type: :integer
  field :match_draw_points, type: :integer
  field :match_lost_points, type: :integer
  field :match_hattrick_earning, type: :integer
  field :game_wo_winner, type: :integer
  field :game_wo_loser, type: :integer

  ## League Settings
  field :league_slots, type: :array

  ## Season Settings
  field :season_times, type: :array
  field :season_min_players, type: :array
  field :season_max_players, type: :array
  field :season_max_steals_same_player, type: :integer
  field :season_max_steals_per_user, type: :integer
  field :season_max_stealed_players, type: :integer
  field :season_default_steal_window_start, type: :integer
  field :season_default_steal_window_end, type: :integer
  field :season_default_player_earnings, type: :integer
  field :season_default_player_earnings_fixed, type: :integer
  field :season_default_mininum_operation, type: :integer
  field :season_tax_for_fired_players, type: :integer
  field :season_default_time_game_confirmation, type: :integer
  field :season_player_value_earning_relation, type: :integer
  field :season_player_high_over, type: :integer
  field :season_player_low_over, type: :integer
  field :season_player_raffle_remaining, type: :array
  field :season_player_raffle_first_order, type: :array
  field :season_club_default_earning, type: :integer
  field :season_club_max_total_wage, type: :integer

  # ## Default Trophies
  # field :trophies, type: :string

  # ## User Settings
  # field :default_league, default: nil, type: :integer, readonly: false
end
