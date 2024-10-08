class Club < ApplicationRecord
  belongs_to :def_team
  belongs_to :user_season

  has_many :club_finances, dependent: :destroy
  has_many :club_players, dependent: :destroy
  has_many :player_seasons, through: :club_players, dependent: :destroy
  has_many :club_championships, dependent: :destroy
  has_many :championships, through: :club_championships, dependent: :destroy
  has_many :rankings, dependent: :destroy
  has_many :championship_positions, dependent: :destroy
  has_many :championship_awards, through: :championships, dependent: :destroy
  has_many :club_awards, dependent: :destroy
  has_many :club_games, dependent: :destroy
  has_many :game_best_player, dependent: :destroy
  has_many :game_cards, dependent: :destroy

  has_many :from_club_player_transactions, class_name: "PlayerTransaction", foreign_key: 'from_club_id', dependent: :destroy
  has_many :to_club_player_transactions, class_name: "PlayerTransaction", foreign_key: 'to_club_id', dependent: :destroy

  has_many :from_club_exchanges, class_name: "ClubExchange", foreign_key: 'from_club_id', dependent: :destroy
  has_many :to_club_exchanges, class_name: "ClubExchange", foreign_key: 'to_club_id', dependent: :destroy
  
  has_many :club_bestplayers

  ## Settings
  jsonb_accessor :details,
    team_formation: [:integer, default: nil],
    formation_pos: [:jsonb, array: true, default: []],
    stealed_times: :integer,
    steal_times: :integer,
    stealer: [:integer, array: true, default: []]

  def self.get_players(club_id, platform)
    ClubPlayer.includes(:club).where(club_id: club_id).order_by_position(platform)
  end

  def self.getUser(club_id, season_id)
    User.joins(user_seasons: :clubs).where(user_seasons: {season_id: season_id}, clubs: {id: club_id}).first
  end

  def self.getTeamStrength(user_id, season_id)
    User.find(user_id).club_players.where(user_seasons: {season_id: season_id}).joins(:player_season, :def_player).sum(Arel.sql("CAST(def_players.details -> 'attrs' ->> 'overallRating' AS int)"))
  end

  def self.getFunds(club_id)
    Club.find(club_id).club_finances.order("club_finances.updated_at DESC").first.balance
  end

  def self.getTeamTotalWage(club_id)
    wage = Money.new(0)
    Club.find(club_id).player_seasons.find_each do |player_season|
      wage += player_season.salary
    end

    wage
  end

  def self.getClubValue(club_id, season)
    Club.getTeamTotalWage(club_id) * season.preferences["player_value_earning_relation"]
  end
end
