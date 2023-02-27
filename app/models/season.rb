class Season < ApplicationRecord
  include Hashid::Rails 
  has_noticed_notifications

  include PublicActivity::Model
  tracked owner: Proc.new{ |controller, model| controller.current_user }
  
  belongs_to :league
  has_many :user_seasons, dependent: :destroy
  has_many :users, through: :user_seasons
  #has_many :notifications, foreign_key: :notifiable_id
  #has_many :notifications, dependent: :destroy
  has_many :player_seasons, dependent: :destroy
  #has_many :rankings, dependent: :destroy
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
    time_game_confirmation: :datetime,
    raffle_low_over: :integer,
    raffle_high_over: :integer,
    raffle_switches: :integer,
    raffle_remaining: :string,
    saction_clubs_choosing: :integer,
    saction_players_choosing: :integer,
    saction_transfer_window: :integer,
    saction_player_steal: :integer,
    saction_change_wage: :integer,
    award_firstplace: :string,
    award_secondplace: :string,
    award_thirdplace: :string,
    award_fourthplace: :string,
    award_goaler: :string,
    award_assister: :string,
    award_fairplay: :string

    
  def self.getActive(user)
    getUser = User.find(user)
    if !getUser.preferences['active_league'].blank?
      season = Season.where("league_id = #{getUser.preferences['active_league']} and (status = 0 OR status = 1)")
      if season.count > 0
        return season.first.id
      end 
    end
    return nil
  end

  def self.getStatus(season_id)
		status = {
			"0": ["not_started", "Não Iniciado", "warning"],
			"1": ["season_running", "Em Andamento", "success"],
			"2": ["season_finished", "Encerrada", "secondary"]
		}
		season = Season.find(season_id)
		return status[:"#{season.status}"]
	end

end
