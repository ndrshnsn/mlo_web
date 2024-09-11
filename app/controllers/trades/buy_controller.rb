class Trades::BuyController < ApplicationController
  before_action :set_controller_vars
  breadcrumb "dashboard", :root_path, match: :exact, turbo: "false"
  breadcrumb "trades.main", :trades_path, match: :exact, frame: "main_frame"

  def index
    breadcrumb "trades.buy.main", :trades_buy_path, match: :exact, frame: "main_frame"

    season_platform = @season.preferences["raffle_platform"]

    @clubs = Club.joins(:user_season).includes(:def_team, user_season: :user).where(user_seasons: { season_id: @season.id } )
    @def_countries = DefCountry.getSorted
    @ages = DefPlayer.get_ages(season_platform)
    @player_position = DefPlayerPosition.get_sorted(season_platform)

    higher_over = DefPlayer.where(platform: season_platform).order(Arel.sql("def_players.details -> 'attrs' ->> 'overallRating' DESC")).limit(1)
    higher_over_initial_salary = DefPlayer.getSeasonInitialSalary(@season, higher_over.first)
    lower_over = DefPlayer.where(platform: season_platform).order(Arel.sql("def_players.details -> 'attrs' ->> 'overallRating' ASC")).limit(1)
    lower_over_initial_salary = DefPlayer.getSeasonInitialSalary(@season, lower_over.first)

    @overs = []
    for i in (lower_over.first.details["attrs"]["overallRating"]..higher_over.first.details["attrs"]["overallRating"]).step(1)
    	@overs << {
    		value: i,
    		reference: i
    	}
    end

    higher_transfer_fee = PlayerSeason.where(player_seasons: { season_id: @season.id } ).order(player_seasons: { salary_cents: :desc} ).first.salary
    higher_transfer_fee = higher_over_initial_salary if higher_over_initial_salary > higher_transfer_fee
    lower_transfer_fee =  PlayerSeason.where(player_seasons: { season_id: @season.id } ).order(player_seasons: { salary_cents: :asc} ).first.salary
    lower_transfer_fee = lower_over_initial_salary if lower_over_initial_salary < lower_transfer_fee
    
    @pValue = []
    for i in (lower_transfer_fee.cents..higher_transfer_fee.cents).step(@season.default_mininum_operation_cents)
    	@pValue << {
    		value: Money.from_cents(i*@season.preferences["player_value_earning_relation"]),
    		reference: i
    	}
    end
    @pValue << {
      value: Money.from_cents(higher_transfer_fee*@season.preferences["player_value_earning_relation"]),
      reference: higher_transfer_fee.cents
    }

  end

  def confirm
    player = DefPlayer.find(params[:id])
    show_step(AppServices::Trades::Buy.call(@club, @season, player), t(".success"))
  end

  def show_step(resolution, success_message)
    respond_to do |format|
      if resolution.success?
        flash.now["success"] = success_message
        format.html { redirect_to trades_buy_path, notice: success_message }
      else
        flash.now["error"] = I18n.t("defaults.errors.championship.#{resolution.error}")
        format.html { render :details, status: :unprocessable_entity }
      end
      format.turbo_stream { render "show_step" }
    end
  end

  def set_controller_vars
    @season = Season.find(session[:season])
    @club = User.getClub(current_user.id, @season.id)
  end

  def get_proc_dt
    render json: User::Trades::BuyDatatable.new(view_context)
  end
end