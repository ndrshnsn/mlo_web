class PlayerSeason < ApplicationRecord
  ## Details
  jsonb_accessor :details,
    salary: :integer,
    stealed_times: :integer,
    ycard: :integer,
    rcard: :integer

  belongs_to :def_player
  belongs_to :season
  has_one :def_player_position, through: :def_player
  has_many :player_season_finances, dependent: :destroy
  # has_many :player_sells, dependent: :destroy
  has_many :club_players
  has_many :games
  has_many :player_transactions
  has_many :club_games
  has_many :club_game_assists, foreign_key: "assist_id", class_name: "ClubGame"
  has_many :game_cards
  has_many :game_best_players

  attribute :goals, type: :integer, default: 0
  attribute :assists, type: :integer, default: 0
  attribute :fairplay, type: :integer, default: 0
  attribute :bestplayer, type: :integer, default: 0

  def self.getPlayerPass(player_season, season)
    player_season.details["salary"] * season.preferences["player_value_earning_relation"]
  end
end
