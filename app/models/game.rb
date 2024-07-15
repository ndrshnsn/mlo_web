class Game < ApplicationRecord
  belongs_to :championship
  belongs_to :visitor, class_name: "Club"
  belongs_to :home, class_name: "Club"
  belongs_to :eresults, class_name: "Club", optional: true
  belongs_to :player_season, optional: true
  has_one :game_best_player, dependent: :destroy
  has_many :club_games, dependent: :destroy
  has_many :game_cards, dependent: :destroy
  has_many :club_finances, foreign_key: :source_id, dependent: :destroy
  has_many :notifications, as: :recipient, dependent: :destroy
  has_many :rankings, foreign_key: :source_id, dependent: :destroy

  def self.translate_status(code)
    status = {
      0 => ["not_started", I18n.t("game.status.not_started"), "secondary"],
      1 => ["running", I18n.t("game.status.running"), "info"],
      2 => ["running", I18n.t("game.status.result_confirmation"), "warning"],
      3 => ["finished", I18n.t("game.status.finished"), "primary"]
    }
    status[code]
  end

  def self.translate_subtype(code)
    status = {
      1 => ["running", I18n.t("game.status.contest"), "danger"],
      2 => ["revoked", I18n.t("game.status.revoked"), "secondary"],
      3 => ["wo", I18n.t("game.status.wo"), "warning"]
    }
    status[code]
  end

  def self.get_running(season_id)
    Game.joins(:championship).where("championships.season_id = ? AND ( games.status > ? OR games.status < ?)", season_id, 0, 3)
  end

  def self.start_permission(game)
    championship = game.championship
    permitted = false

    return if championship.status == 0
    if championship.status > 0
      case championship.preferences["ctype"]
      when "league"
        permitted = true if championship.status == 10 && game.phase == 1
        permitted = true if ([11, 12].include? championship.status) && ([1, 2].include? game.phase)
        permitted = true if ([13, 14].include? championship.status) && game.phase > 2
      end
    end

    permitted
  end
end
