class Club < ApplicationRecord
  belongs_to :def_team
  belongs_to :user_season

  has_many :club_finances, dependent: :destroy
  has_many :club_players, dependent: :destroy
  has_many :player_seasons, through: :club_players
  has_many :club_championships, dependent: :destroy
  has_many :championships, through: :club_championships
  #has_many :rankings, dependent: :destroy
  has_many :championship_positions, through: :championships
  #has_many :championship_awards, through: :championships
  #has_many :from_club, class_name: 'PlayerTransaction', foreign_key: :from_club_id, dependent: :destroy
  #has_many :to_club, class_name: 'PlayerTransaction', foreign_key: :to_club_id, dependent: :destroy
  #has_many :club_bestplayers
  
  ## Settings
  jsonb_accessor :details,
    team_formation: [:integer, default: nil],
    formation_pos: [:jsonb, array: true, default: []],
    stealed_times: :integer,
    steal_times: :integer,
    stealer: [:integer, array: true, default: []]

  def self.getUser(club_id, season_id)
    return User.joins(user_seasons: :clubs).where(user_seasons: { season_id: season_id }, clubs: { id: club_id }  ).first
  end

  def self.getTeamStrength(user_id, season_id)
    return User.find(user_id).club_players.where(user_seasons:{season_id: season_id}).joins(:player_season, :players).sum(Arel.sql("CAST(players.details -> 'attrs' ->> 'overallRating' AS int)"))
  end

  def self.getFunds(club_id)
    return Club.find(club_id).club_finances.order('club_finances.updated_at DESC').pluck('club_finances.balance')[0]
  end

  def self.getTeamTotalWage(club_id)
    return Club.find(club_id).player_seasons.sum("CAST(player_seasons.details->>'salary' AS int)")
  end

  def self.getClubValue(club_id, season)
    salary = Club.find(club_id).player_seasons.sum("CAST(player_seasons.details->>'salary' AS int)")
    return salary*season.preferences["player_value_earning_relation"].to_i
  end
end
