class Championship < ApplicationRecord
  include Hashid::Rails
  include BadgeUploader::Attachment(:badge)

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
    time_course: :datetime,
    time_start: :datetime,
    time_end: :datetime,
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
    hattrick_earning: :integer,
    cards_suspension: :boolean,
    match_best_player: :boolean,
    match_winning_earning: :integer,
    match_draw_earning: :integer,
    match_lost_earning: :integer,
    match_goal_earning: :integer,
    match_goal_lost: :integer,
    match_yellow_card_loss: :integer,
    match_red_card_loss: :integer,
    match_winning_ranking: :integer,
    match_lost_ranking: :integer,
    match_draw_ranking: :integer

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
    statuses = {
      0 => ["not_started", I18n.t("championship.status.not_started"), "warning", ""],
      1 => ["running", I18n.t("championship.status.running"), "success", ""],

      10 => ["running", I18n.t("championship.status.league.round"), "success", "firstRound"],
      11 => ["running", I18n.t("championship.status.league.return"), "success", "secondRound"],
      12 => ["running", I18n.t("championship.status.league.round_return"), "success", "firstAndSecondRound"],
      13 => ["running", I18n.t("championship.status.league.semifinals"), "success", "semifinals"],
      14 => ["running", I18n.t("championship.status.league.finals_third_fourth"), "success", "[3rd4th, finals]"],

      100 => ["finished", I18n.t("championship.status.finished"), "secondary", ""]
    }
    statuses[code]
  end

  def self.translate_phase(code)
    phase = {
      1 => [I18n.t("championship.phase.round"), "secondary"],
      2 => [I18n.t("championship.phase.second_round"), "secondary"],
      3 => [I18n.t("championship.phase.semifinals"), "warning"],
      4 => [I18n.t("championship.phase.finals"), "success"],
      5 => [I18n.t("championship.phase.thirdfourth"), "info"]
    }
    phase[code]
  end


  def self.get_running(season_id)
    return Championship.where(season_id: season_id).where("status > ? AND status < ?", 0, 100)
  end

  def self.getGoalers(championship)
    PlayerSeason.joins('LEFT OUTER JOIN "club_games" ON "club_games"."player_season_id" = "player_seasons"."id"').where(club_games: {game_id: Game.where(championship_id: championship.id, status: 100)}).includes(:player).select("player_seasons.id, player_seasons.player_id, COUNT(player_seasons.id) AS goals").group(:id).order("goals desc")
  end

  def self.getAssisters(championship)
    PlayerSeason.joins('LEFT OUTER JOIN "club_games" ON "club_games"."assist_id" = "player_seasons"."id"').where(club_games: {game_id: Game.where(championship_id: championship.id, status: 100)}).includes(:player).select("player_seasons.id, player_seasons.player_id, COUNT(player_seasons.id) AS assists").group(:id).order("assists desc")
  end

  def self.getFairPlay(championship)
    PlayerSeason.joins('LEFT OUTER JOIN "game_cards" ON "game_cards"."player_season_id" = "player_seasons"."id"').where(game_cards: {game_id: Game.where(championship_id: championship.id, status: 100)}).includes(:player).select("player_seasons.id, player_seasons.player_id, COUNT(game_cards.ycard) AS count_ycard, COUNT(game_cards.rcard) AS count_rcard").group(:id).order("count_rcard desc, count_ycard desc")
  end

  def self.getBestPlayer(championship)
    PlayerSeason.joins('LEFT OUTER JOIN "club_bestplayers" ON "club_bestplayers"."player_season_id" = "player_seasons"."id"').where(club_bestplayers: {game_id: Game.where(championship_id: championship.id, status: 100)}).includes(:player).select("player_seasons.id, player_seasons.player_id, COUNT(player_seasons.id) AS bestplayer").group(:id).order("bestplayer desc")
  end

  def self.get_game_sequence(championship)
    games = Game.where(championship_id: championship.id).order(gsequence: :desc)
    games.size > 0 ? games.last.gsequence : 0
  end
end
