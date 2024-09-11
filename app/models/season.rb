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
  has_many :clubs, through: :user_seasons, dependent: :destroy
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
    allow_increase_earnings: :string,
    allow_decrease_earnings: :string,
    allow_negative_funds: :boolean,
    operation_tax: :integer,
    player_value_earning_relation: :integer,
    fire_tax: :string,
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

  monetize :club_default_earning_cents, as: :club_default_earning
  monetize :club_max_total_wage_cents, as: :club_max_total_wage
  monetize :default_mininum_operation_cents, as: :default_mininum_operation
  monetize :fire_tax_fixed_cents, as: :fire_tax_fixed
  monetize :default_player_earnings_fixed_cents, as: :default_player_earnings_fixed

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
    ClubFinance.where(club_id: Season.getClubs(season.id).select(:id)).order(club_id: :desc, created_at: :desc).sum(:value_cents) || 0
  end

  def self.get_player_fire_tax(season_id, player_season_id)
    season = Season.find(season_id)
    player = PlayerSeason.find(player_season_id)
    case season.preferences["fire_tax"]
    when "wage"
      tax = player.salary
    when "fixed"
      tax = season.fire_tax_fixed
    when "none"
      tax = 0
    end
    tax
  end

  def self.getRanking(season, club_id = nil, position = nil, date_start=nil, date_finish=nil)
		ranking = []

		## Get All Sesons for This League
		lSeasons = Season.where(league_id: season.league.id).pluck(:id)

		## Get All League Users
		lUsers = season.league.user_leagues.pluck(:user_id)

		lUsers.each_with_index do |user,i|
			uClubs = UserSeason.joins(:season, :clubs).where(seasons: { id:  season.id}, user_seasons: { user_id: user }).order(created_at: :desc).pluck('clubs.id')
			rPoints = Ranking.where(club_id: uClubs).order(created_at: :desc)
			if rPoints.first.nil?
				cPoints = 0
			else
				cPoints = rPoints.first.balance.nil? ? 0 : rPoints.first.balance
			end

			ranking << {
				user_id: user,
				club_id: uClubs[0],
				points: cPoints
			}
		end

		if ranking.size > 0
    		ranking.sort_by!{ |el| el[:points] }.reverse!
    	end

    	if club_id
    		rPosition = []
    		rPosition.push(ranking.index{|club| club[:club_id] == club_id} + 1)
    		rPosition.push(ranking.select{|club| club[:club_id] == club_id})
    		return rPosition
    	else
			return ranking
		end


		# if date_start || date_finish
		# 	query = "select id, club_id, points, operation, source_id, source_type, created_at, updated_at,(
		# 	        select greatest(sum(points),0)
		# 	        from rankings
		# 	        where season_id = #{season.id}
		# 	        and (created_at >= '#{date_start}' and created_at <= '#{date_finish}')
		# 	        and club_id = rank.club_id
		# 	    ) as total
		# 	    from rankings as rank 
		# 	    where season_id = #{season.id}
			    
		# 	    and (club_id = #{club_id})
		# 	    and id in (
		# 	        select id from (
		# 	            select distinct on (club_id) club_id, id
		# 	            from rankings
		# 	            where season_id = #{season.id}
		# 	        ) as ids2
		# 	    ) order by total desc"
		# else
		# 	query = "select id, club_id, points, operation, source_id, source_type, created_at, updated_at,(
		# 	        select greatest(sum(points),0)
		# 	        from rankings
		# 	        where season_id = #{season.id}
		# 	        and club_id = rank.club_id
		# 	    ) as total
		# 	    from rankings as rank 
		# 	    where season_id = #{season.id}
		# 	    and id in (
		# 	        select id from (
		# 	            select distinct on (club_id) club_id, id
		# 	            from rankings
		# 	            where season_id = #{season.id}
		# 	        ) as ids2
		# 	    ) order by total desc"
		# end

		# ranking = Ranking.select("*").from(Arel.sql("(#{query}) as t"))

		# if ranking.size > 0
		# 	if position == true
		#   		position = ranking.index(ranking.find { |l| l.club_id == club_id }) + 1
		#   		return position
		#   	else
		#   		return ranking
		#   	end
		# end
	end

end
