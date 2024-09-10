class Championship < ApplicationRecord
  include BadgeUploader::Attachment(:badge)
  extend FriendlyId
  friendly_id :name, use: :scoped, scope: :season_id

  belongs_to :season
  has_many :club_championships, dependent: :destroy
  has_many :clubs, through: :club_championships
  has_many :games, dependent: :destroy
  has_many :notifications, as: :recipient, dependent: :destroy
  has_many :rankings, foreign_key: :source_id, dependent: :destroy
  has_many :championship_positions, dependent: :destroy
  has_many :championship_awards, dependent: :destroy

  ## Settings
  jsonb_accessor :preferences,
    time_course: :date,
    time_start: :date,
    time_end: :date,
    ctype: :string,
    league_two_rounds: :boolean,
    league_finals: :boolean,
    league_criterion: :string,
    cup_group_two_rounds: :boolean,
    cup_number_of_groups: :integer,
    cup_teams_that_classify: :integer,
    cup_switching: :string,
    cup_criterion: :string,
    bracket_two_rounds: :boolean,
    cards_suspension: :boolean,
    match_best_player: :boolean,
    match_winning_ranking: :integer,
    match_lost_ranking: :integer,
    match_draw_ranking: :integer

  monetize :match_winning_earning_cents, as: :match_winning_earning
  monetize :match_draw_earning_cents, as: :match_draw_earning
  monetize :match_lost_earning_cents, as: :match_lost_earning
  monetize :match_goal_earning_cents, as: :match_goal_earning
  monetize :match_goal_lost_cents, as: :match_goal_lost
  monetize :match_yellow_card_loss_cents, as: :match_yellow_card_loss
  monetize :match_red_card_loss_cents, as: :match_red_card_loss
  monetize :hattrick_earning_cents, as: :hattrick_earning

  def self.types(type = nil)
    championship_types = [
      {
        type: "league",
        name: I18n.t("championship.types.league")
      }
      # {
      #   type: "cup",
      #   name: I18n.t('championship.types.cup')
      # },
      # {
      #   type: "brackets",
      #   name: I18n.t('championship.types.brackets')
      # }
    ]
    if type
      championship_types.select { |championship_type| championship_type[:type] == type }
    else
      championship_types
    end
  end

  def self.translate_status(code)
    ##
    # main, i18n, status color
    statuses = {
      0 => ["not_started", I18n.t("championship.status.not_started"), "warning"],
      1 => ["running", I18n.t("championship.status.running"), "success"],

      10 => ["running", I18n.t("championship.status.league.round"), "success"],
      11 => ["running", I18n.t("championship.status.league.return"), "success"],
      12 => ["running", I18n.t("championship.status.league.round_return"), "success"],
      13 => ["running", I18n.t("championship.status.league.semifinals"), "success"],
      14 => ["running", I18n.t("championship.status.league.finals_third_fourth"), "success"],

      100 => ["finished", I18n.t("championship.status.finished"), "secondary"]
    }
    statuses[code]
  end

  def self.translate_phase(code)
    ##
    # i18n, color, penalty
    phase = {
      1 => [I18n.t("championship.phase.round"), "secondary", false],
      2 => [I18n.t("championship.phase.second_round"), "secondary", false],

      98 => [I18n.t("championship.phase.semifinals"), "warning", true],
      99 => [I18n.t("championship.phase.thirdfourth"), "info", true],
      100 => [I18n.t("championship.phase.finals"), "success", true]
    }
    phase[code]
  end

  def self.get_running(season_id)
    Championship.where(season_id: season_id).where("status > ? AND status < ?", 0, 100)
  end

  def self.getGoalers(championship,items=nil)
    goalers = PlayerSeason.left_joins(:club_games, :def_player)
      .where(club_games: {game_id: Game.where(championship_id: championship.id)})
      .select("player_seasons.id, player_seasons.def_player_id, COUNT(player_seasons.id) AS goals")
      .group(:id)
      .order("goals desc")
    goalers = goalers.limit(items) if items
    goalers.to_a
  end

  def self.getAssisters(championship,items=nil)
    join_query = <<-SQL.squish
      JOIN club_games 
      ON player_seasons.id = club_games.assist_id
    SQL

    assisters = PlayerSeason
      .joins(join_query)
      .where(club_games: {game_id: Game.where(championship_id: championship.id)})
      .select("player_seasons.id, player_seasons.def_player_id, COUNT(player_seasons.id) AS assists")
      .includes(:def_player)
      .group(:id)
      .order("assists desc")
    assisters = assisters.limit(items) if items
    assisters.to_a
  end

  def self.getFairPlay(championship,items=nil)
    fairplay = PlayerSeason.left_joins(:game_cards, :def_player)
      .where(game_cards: {game_id: Game.where(championship_id: championship.id)})
      .select("player_seasons.id, player_seasons.def_player_id, COUNT(game_cards.ycard) AS count_ycard, COUNT(game_cards.rcard) AS count_rcard")
      .group(:id)
      .order("count_rcard desc, count_ycard desc")
    fairplay = fairplay.limit(items) if items
    fairplay.to_a
  end

  def self.getBestPlayer(championship,items=nil)
    bestplayer = PlayerSeason.left_joins(:game_best_players, :def_player)
      .where(game_best_players: {game_id: Game.where(championship_id: championship.id)})
      .select("player_seasons.id, player_seasons.def_player_id, COUNT(player_seasons.id) AS bestplayer")
      .group(:id)
      .order("bestplayer desc")
    bestplayer = bestplayer.limit(items) if items
    bestplayer.to_a
  end

  def self.get_game_sequence(championship)
    games = Game.where(championship_id: championship.id).order(gsequence: :asc)
    (games.size > 0) ? games.last.gsequence : 0
  end

  def self.get_standing(championship, items = nil, group_number = nil)
    standing = ClubChampionship.where(championship_id: championship)
    standing = standing.where(group: group_number) if group_number
    standing = standing.order(points: :desc, goalsdiff: :desc, wins: :desc, goalsfor: :desc)
    standing = standing.limit(items) if items
    standing
  end
end
