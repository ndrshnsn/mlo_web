class Season < ApplicationRecord
  #has_noticed_notifications
  audited

  belongs_to :league
  has_many :user_seasons, dependent: :destroy
  has_many :users, through: :user_seasons
  has_many :notifications, as: :recipient, dependent: :destroy
  has_many :championships, dependent: :destroy
  has_many :player_seasons, dependent: :destroy
  has_many :season_awards, dependent: :destroy
  has_many :rankings, dependent: :destroy
  has_many :clubs, through: :user_seasons
  has_rich_text :advertisement

  jsonb_accessor :preferences,
    min_players: :integer,
    max_players: :integer,
    allow_fire_player: :string,
    change_player_out_of_window: :string,
    enable_players_loan: :string,
    enable_players_exchange: :string,
    enable_player_steal: :string,
    max_steals_same_player: :integer,
    max_steals_per_user: :integer,
    max_stealed_players: :integer,
    steal_window_start: :integer,
    steal_window_end: :integer,
    add_value_after_steal: :integer,
    allow_money_transfer: :string,
    default_player_earnings: :string,
    default_player_earnings_fixed: :integer,
    allow_increase_earnings: :string,
    allow_decrease_earnings: :string,
    allow_negative_funds: :boolean,
    operation_tax: :integer,
    player_value_earning_relation: :integer,
    club_default_earning: :integer,
    club_max_total_wage: :integer,
    fire_tax: :string,
    fire_tax_fixed: :integer,
    default_mininum_operation: :integer,
    time_game_confirmation: :integer,
    raffle_platform: :string,
    raffle_low_over: :integer,
    raffle_high_over: :integer,
    raffle_remaining: :string,
    saction_clubs_choosing: :integer,
    saction_players_choosing: :integer,
    saction_transfer_window: :integer,
    saction_player_steal: :integer,
    saction_change_wage: :integer

  def self.getActive(user)
    getUser = User.find(user)
    if getUser.preferences["active_league"].present?
      season = Season.where("league_id = '#{getUser.preferences["active_league"]}' and (status = 0 OR status = 1)")
      if season.count > 0
        return season.first.id
      end
    end
    nil
  end

  def self.valid_users(season_id)
    User.joins(:user_seasons).where("user_seasons.season_id = ? AND (users.preferences -> 'fake')::Bool = ?", season_id, false)
  end

  def self.translate_status(code)
    status = {
      0 => ["not_started", "Não Iniciado", "warning"],
      1 => ["season_running", "Em Andamento", "success"],
      2 => ["season_finished", "Encerrada", "secondary"]
    }
    status[code]
  end

  def self.getClubs(season_id, fake = nil)
    clubs = Club.includes([user_season: :user], :def_team).where(user_seasons: { season_id: season_id })
    clubs.where("(users.preferences -> 'fake')::Bool = ?", fake) if !fake.nil?
    clubs
  end

  def self.getBalance(season)
    ClubFinance.where(club_id: Season.getClubs(season.id).select(:id)).order(club_id: :desc, created_at: :desc).sum(:value) || 0
  end

  def self.get_player_fire_tax(season_id, player_season_id)
    season = Season.find(season_id)
    player = PlayerSeason.find(player_season_id)
    case season.preferences["fire_tax"]
    when "wage"
      tax = player.details["salary"]
    when "fixed"
      tax = season.preferences["fire_tax_fixed"]
    when "none"
      tax = 0
    end
    tax
  end
end
