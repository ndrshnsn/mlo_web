class Manager::SeasonsController < ApplicationController
  authorize_resource class: false
  before_action :set_local_vars
  breadcrumb "dashboard", :root_path, match: :exact
  breadcrumb "manager.seasons.main", :manager_seasons_path, match: :exact

  def index
    get_current_seasons
    if @season
      @users = User.joins(:user_leagues).where("league_id = ?", @league.id)
    end
  end

  def check_season_name
    season = Season.exists?(name: params[:season][:name], league_id: @league.id) ? :unauthorized : :ok
    render body: nil, status: season
  end

  def get_current_seasons
    @seasons = League.get_seasons(@league.id)
  end

  def new
    @season = Season.new
    @pAvailablePlayers = get_base_players
    @tAvailablePlayers = 0
    @pAvailablePlayers.uniq.each do |pPosition|
      @tAvailablePlayers += pPosition[1]
    end
    @tAvailablePlayersPP = @pAvailablePlayers.uniq
    @awards = League.get_awards(@league.id)
    @award_result_type = AppServices::Award.new().list_awards
  end

  def get_susers_dt
    season = Season.find_by_hashid(params[:season])
    render json: Manager::SeasonUsersDatatable.new(view_context, season: season.id)
  end

  def get_base_players(lowOver = AppConfig.season_player_low_over.to_i, highOver = AppConfig.season_player_high_over.to_i, platform = nil)
    platform_dna = platform.nil? ? @league.platform : helpers.get_platforms(platform: platform, dna: true)
    platform ||= @league.platform
    availablePlayers = []
    AppConfig.season_player_raffle_first_order.find { |key| key.include?(platform_dna) }[1].each do |position|
      getPlayers = DefPlayer.left_outer_joins(:def_player_position).where("def_players.platform = ? AND def_players.active = ? AND def_player_positions.name = ? AND (def_players.details -> 'attrs' ->> 'overallRating')::Integer >= ? AND (def_players.details -> 'attrs' ->> 'overallRating')::Integer <= ?", platform, true, position, lowOver, highOver)
      availablePlayers << [position, getPlayers.size]
    end
    availablePlayers
  end

  def get_available_players
    @noSpaces = false
    @pAvailablePlayers = get_base_players(params[:season][:raffle_low_over], params[:season][:raffle_high_over], params[:platform])
    @tAvailablePlayers = 0
    @pAvailablePlayers.uniq.each do |pPosition|
      @tAvailablePlayers += pPosition[1]
    end
    @tAvailablePlayersPP = @pAvailablePlayers.each { |val| val[1] = val[1] - (@league.user_leagues.size.to_i * 2) }.uniq
    @tAvailablePlayersPP.each do |pSpaces|
      if pSpaces[1] <= 5
        @noSpaces = true
        flash.now[:error] = t(".no_spaces_check")
      end
    end
    respond_to do |format|
      format.turbo_stream
    end
  end

  def ftax
    @type = params[:type]
    @sStarted = false
    if session[:season]
      @season = Season.find(session[:season])
      @sStarted = @season.status > 0
    end
  end

  def pearnings
    @type = params[:type]
    @sStarted = false
    if session[:season]
      @season = Season.find(session[:season])
      @sStarted = @season.status > 0
    end
  end

  def user_players
    @season = Season.find_by_hashid(params[:id])
    @user = User.friendly.find(params[:user])
    @teamPlayers = User.getTeamPlayers(@user.id, @season.id)
  end

  def settings
    @season = Season.find_by_hashid(params[:id])
    @awards = League.get_awards(@league.id)
    @award_result_type = AppServices::Award.new().list_awards
  end

  def create
    @season = Season.new
    @season.name = season_params[:name]
    @season.start = DateTime.parse(season_params[:start_date])
    @season.duration = season_params[:time].to_i
    @season.league_id = current_user.preferences["active_league"]
    @season.advertisement = season_params[:advertisement]
    @season.status = 0
    @season.preferences = {
      min_players: season_params[:min_players].to_i,
      max_players: season_params[:max_players].to_i,
      allow_fire_player: season_params[:allow_fire_player],
      change_player_out_of_window: season_params[:change_player_out_of_window],
      enable_players_loan: season_params[:enable_players_loan],
      enable_players_exchange: season_params[:enable_players_exchange],
      enable_player_steal: season_params[:enable_player_steal],
      max_steals_same_player: season_params[:max_steals_same_player].to_i,
      max_steals_per_user: season_params[:max_steals_per_user].to_i,
      max_stealed_players: season_params[:max_stealed_players].to_i,
      steal_window_start: season_params[:steal_window_start],
      steal_window_end: season_params[:steal_window_end],
      add_value_after_steal: season_params[:add_value_after_steal].to_i,
      allow_money_transfer: season_params[:allow_money_transfer],
      default_player_earnings: season_params[:default_player_earnings],
      default_player_earnings_fixed: season_params[:default_player_earnings_fixed].to_i,
      allow_increase_earnings: season_params[:allow_increase_earnings],
      allow_decrease_earnings: season_params[:allow_decrease_earnings],
      allow_negative_funds: season_params[:allow_negative_funds],
      club_default_earning: season_params[:club_default_earning].to_i,
      club_max_total_wage: season_params[:club_max_total_wage].to_i,
      operation_tax: season_params[:operation_tax].to_i,
      player_value_earning_relation: season_params[:player_value_earning_relation].to_i,
      fire_tax: season_params[:fire_tax],
      fire_tax_fixed: season_params[:fire_tax_fixed].to_i,
      default_mininum_operation: season_params[:default_mininum_operation].to_i,
      time_game_confirmation: season_params[:time_game_confirmation],
      raffle_platform: season_params[:raffle_platform],
      raffle_low_over: season_params[:raffle_low_over].to_i,
      raffle_high_over: season_params[:raffle_high_over].to_i,
      raffle_remaining: season_params[:raffle_remaining],
      saction_players_choosing: 0,
      saction_transfer_window: 0,
      saction_player_steal: 0,
      saction_change_wage: 0,
      saction_clubs_choosing: 0
    }

    AppServices::Award.new().list_awards.each do |award|
      @season.preferences["award_#{award[:position]}"] = award_params[:award][award[:position].to_sym].to_i
    end

    respond_to do |format|
      if @season.save!
        User.joins(:user_leagues).where("league_id = ? AND status = ?", @league.id, true).each do |user|
          user_season = UserSeason.create(user_id: user.id, season_id: @season.id)
        end

        SeasonNotification.with(
          season: @season,
          league: @season.league_id,
          icon: "stack",
          push: true,
          push_type: "user",
          push_message: "#{t(".wnotify_subject", season: @season.name)}||#{t(".wnotify_text")}",
          type: "new"
        ).deliver_later(current_user)

        get_current_seasons
        format.html { redirect_to manager_seasons_path, notice: t(".success") }
        format.turbo_stream { flash.now["success"] = t(".success") }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def update
    @season = Season.find_by_hashid(params[:id])
    @season.name = season_params[:name]
    @season.start = DateTime.parse(season_params[:start_date])
    @season.duration = season_params[:time]
    @season.league_id = current_user.preferences["active_league"]
    @season.advertisement = season_params[:advertisement]
    @season.preferences = {
      min_players: season_params[:min_players].to_i,
      max_players: season_params[:max_players].to_i,
      allow_fire_player: season_params[:allow_fire_player],
      change_player_out_of_window: season_params[:change_player_out_of_window],
      enable_players_loan: season_params[:enable_players_loan],
      enable_players_exchange: season_params[:enable_players_exchange],
      enable_player_steal: season_params[:enable_player_steal],
      max_steals_same_player: season_params[:max_steals_same_player].to_i,
      max_steals_per_user: season_params[:max_steals_per_user].to_i,
      max_stealed_players: season_params[:max_stealed_players].to_i,
      steal_window_start: season_params[:steal_window_start],
      steal_window_end: season_params[:steal_window_end],
      add_value_after_steal: season_params[:add_value_after_steal].to_i,
      allow_money_transfer: season_params[:allow_money_transfer],
      default_player_earnings: season_params[:default_player_earnings],
      default_player_earnings_fixed: season_params[:default_player_earnings_fixed].to_i,
      allow_increase_earnings: season_params[:allow_increase_earnings],
      allow_decrease_earnings: season_params[:allow_decrease_earnings],
      allow_negative_funds: season_params[:allow_negative_funds],
      club_default_earning: season_params[:club_default_earning].to_i,
      club_max_total_wage: season_params[:club_max_total_wage].to_i,
      operation_tax: season_params[:operation_tax].to_i,
      player_value_earning_relation: season_params[:player_value_earning_relation].to_i,
      fire_tax: season_params[:fire_tax],
      fire_tax_fixed: season_params[:fire_tax_fixed].to_i,
      default_mininum_operation: season_params[:default_mininum_operation].to_i,
      time_game_confirmation: season_params[:time_game_confirmation],
      raffle_platform: season_params[:raffle_platform],
      raffle_low_over: season_params[:raffle_low_over].to_i,
      raffle_high_over: season_params[:raffle_high_over].to_i,
      raffle_remaining: season_params[:raffle_remaining],
      saction_players_choosing: @season.saction_players_choosing,
      saction_transfer_window: @season.saction_transfer_window,
      saction_player_steal: @season.saction_player_steal,
      saction_change_wage: @season.saction_change_wage,
      saction_clubs_choosing: @season.saction_clubs_choosing
    }

    AppServices::Award.new().list_awards.each do |award|
      @season.preferences["award_#{award[:position]}"] = award_params[:award][award[:position].to_sym].to_i
    end

    respond_to do |format|
      if @season.save!
        format.turbo_stream {flash.now["success"] = t(".success")}
        format.html { redirect_to manager_seasons_path, notice: t(".success") }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def users
    @season = Season.find_by_hashid(params[:id])
  end

  def details
    @season = Season.find_by_hashid(params[:id])

    ## Season Champs
    # @sChampionships = Championship.where(season_id: @season.id)

    ## Season Games
    # @sGames = @sChampionships.joins(:games).where(games: { status: 4 }).size

    ## Season Goals
    # @sGoals = @sChampionships.joins(games: :club_games).size

    ## Season Balance
    # @sBalance = Season.getBalance(@season)

    ## Biggest Transfers
    # @lTransfers = PlayerTransaction.includes(player_season: [player: :player_position]).where(player_seasons: { season_id: @season.id } ).order(transfer_rate: :desc).limit(5)

    @seasons = Season.where(league_id: @league.id).where.not(id: @season.id).order(updated_at: :desc)
  end

  def steps
    @season = Season.find_by_hashid(params[:id])
    case params[:step]
    when "start"
      resolution = ManagerServices::Season::Start.call(@season, current_user)
      success_message = t(".start.success")
    when "start_club_choosing"
      resolution = ManagerServices::Season::ClubChoosing.new(@season, current_user).call_start()
      success_message = t(".start_club_choosing.success")
    when "stop_club_choosing"
      resolution = ManagerServices::Season::ClubChoosing.new(@season, current_user).call_stop()
      success_message = t(".stop_club_choosing.success")
    when "start_players_raffle"
      resolution = ManagerServices::Season::PlayerRaffle.call(@season, current_user)
      success_message = t(".start_players_raffle.success")
    when "start_change_wage"
      resolution = ManagerServices::Season::Wage.call(@season, current_user, "start")
      success_message = t(".start_change_wage.success")
    when "stop_change_wage"
      resolution = ManagerServices::Season::Wage.call(@season, current_user, "stop")
      success_message = t(".stop_change_wage.success")
    when "start_transfer_window"
      resolution = ManagerServices::Season::Transfer.call(@season, current_user, "start")
      success_message = t(".start_transfer_window.success")
    when "stop_transfer_window"
      resolution = ManagerServices::Season::Transfer.call(@season, current_user, "stop")
      success_message = t(".stop_transfer_window.success")
    when "steal_window"
      resolution = ManagerServices::Season::Steal.call(@season, current_user)
      success_message = t(".steal_window.success")
    when "end"
      resolution = ManagerServices::Season::End.call(@season, current_user, params)
      success_message = t(".end.success")
    end

    respond_to do |format|
      if resolution.success?
        format.turbo_stream {flash.now["success"] = success_message}
        format.html { redirect_to manager_seasons_path, notice: success_message }
      else
        flash.now["error"] = I18n.t("defaults.errors.season.#{resolution.error}")
        format.html { render :details, status: :unprocessable_entity }
      end
    end
  end

  def end_season
    @season = Season.find_by_hashid(params[:id])
  end

  def destroy
    @season = Season.find_by_hashid(params[:id])
    respond_to do |format|
      if @season.status == 1
        format.turbo_stream { flash["error"] = t(".in_progress") }
        format.html { render :details, status: :unprocessable_entity, notice: t(".in_progress") }
      else
        if @season.destroy!
          format.turbo_stream { flash["success"] = t(".success") }
          format.html { redirect_to manager_seasons_path, notice: t(".success") }
        else
          format.html { render :details, status: :unprocessable_entity }
        end
      end
    end
  end

  private

  def set_local_vars
    @league = League.find(session[:league])
  end

  def season_params
    params.require(:season).permit(
      :name,
      :start_date,
      :time,
      :min_players,
      :max_players,
      :allow_fire_player,
      :change_player_out_of_window,
      :enable_players_loan,
      :enable_players_exchange,
      :enable_player_steal,
      :max_steals_same_player,
      :max_steals_per_user,
      :max_stealed_players,
      :steal_window_start,
      :steal_window_end,
      :add_value_after_steal,
      :club_default_earning,
      :club_max_total_wage,
      :allow_money_transfer,
      :default_player_earnings,
      :default_player_earnings_fixed,
      :allow_increase_earnings,
      :allow_decrease_earnings,
      :allow_negative_funds,
      :operation_tax,
      :player_value_earning_relation,
      :default_mininum_operation,
      :fire_tax,
      :fire_tax_fixed,
      :time_game_confirmation,
      :raffle_platform,
      :raffle_low_over,
      :raffle_high_over,
      :raffle_switches,
      :raffle_remaining,
      :advertisement
    )
  end

  def award_params
    params.permit(award: {})
  end
end
