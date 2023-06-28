class Manager::SeasonsController < ApplicationController
  authorize_resource class: false
  before_action :set_local_vars
  breadcrumb "dashboard", :root_path, match: :exact
  breadcrumb "manager.seasons.main", :manager_seasons_path, match: :exact

  def index
    @seasons = Season.where(league_id: @league.id).order(updated_at: :desc)
    if @season
      @users = User.joins(:user_leagues).where("league_id = ?", @league.id)
    end
  end

  def check_season_name
    season = Season.exists?(name: params[:season][:name], league_id: @league.id) ? :unauthorized : :ok
    render body: nil, status: season
  end

  def new
    # running_seasons = Season.where("league_id = ? and start_date > ? AND (status = ?  OR status = ?)", session[:league], Date.today.to_time.utc, 0, 1).count > 0 ? false : true

    # if running_seasons == false
    #  flash[:warning] = "Não pode criar outra temporada enquanto uma está em andamento ou agendada."
    #  redirect_to manager_seasons_path
    # else
    season_times = AppConfig.season_times
    @season = Season.new

    # Go through each available raffle position to count availability
    @pAvailablePlayers = get_base_players
    @tAvailablePlayers = 0
    @pAvailablePlayers.uniq.each do |pPosition|
      @tAvailablePlayers += pPosition[1]
    end
    @tAvailablePlayersPP = @pAvailablePlayers.uniq
    @awards = Award.where(league_id: @league.id, status: true)
    @award_result_type = helpers.award_result_types
    # end
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

  def players_raffle
    @season = Season.find_by_hashid(params[:id])
    @seasons = Season.where(league_id: @league.id).where.not(id: @season.id).order(updated_at: :desc)

    ## Go through each season user and check if theres
    # enough players, otw choose them randomly using
    # season defined parameters
    @platform = @season.league.platform
    @uList = UserLeague.where(league_id: current_user.preferences["active_league"], status: true).order(updated_at: :asc).pluck(:user_id)
    @uList2 = UserSeason.where(season_id: @season.id).pluck(:user_id)
    orderedChoosingQueue = @uList - (@uList - @uList2)
    oSelection = eval(AppConfig.season_player_raffle_first_order).find { |key| key.include?(@platform) }[1]

    @orderOfSelection = []
    for i in 1..@season.preferences["max_players"].to_i
      if oSelection.count < i
        @orderOfSelection << {position: "any"}
      elsif oSelection.count >= i
        @orderOfSelection << {position: oSelection[i - 1]}
      end
    end

    orderedChoosingQueue.each do |cQueue|
      userClub = User.getClub(cQueue, @season.id)
      user = User.find(cQueue)
      userSeason = UserSeason.where(user_id: user.id, season_id: @season.id).first
      userPlayers = User.getTeamPlayers(user.id, @season.id)
      ## If user selected just a few players, remove them all and randomize a new list
      if userPlayers.size < @season.preferences["max_players"].to_i
        userPlayers.each do |uPlayer|
          uPlayer.destroy
        end

        @orderOfSelection.each do |oSelection|
          if oSelection[:position] == "any"
            # Get Available players to be injected into Raffle
            @availablePlayers = DefPlayer.left_outer_joins(:def_player_position).where(platform: @platform).where.not(def_players: {id: ClubPlayer.joins(:player_season, :def_players).where(player_seasons: {season_id: @season.id}).pluck("def_players.id")})

            remaining = @season.preferences["raffle_remaining"]
            remainingOverall = remaining.first(2)
            remainingSymbol = remaining.last(1)

            @availablePlayers = if remainingSymbol == "-"
              @availablePlayers.where("def_players.active = ? AND def_players.details -> 'attrs' ->> 'overallRating' >= ? AND def_players.details -> 'attrs' ->> 'overallRating' <= ?", true, @season.preferences["raffle_low_over"], remainingOverall).order(Arel.sql("RANDOM()")).first
            else
              @availablePlayers.where("def_players.active = ? AND def_players.details -> 'attrs' ->> 'overallRating' >= ?", true, remainingOverall).order(Arel.sql("RANDOM()")).first
            end
          else
            @availablePlayers = DefPlayer.left_outer_joins(:def_player_position).where("def_players.platform = ? AND def_players.active = ? AND def_player_positions.name = ? AND def_players.details -> 'attrs' ->> 'overallRating' >= ? AND def_players.details -> 'attrs' ->> 'overallRating' <= ?", @platform, true, oSelection[:position], @season.preferences["raffle_low_over"], @season.preferences["raffle_high_over"]).where.not(def_players: {id: ClubPlayer.joins(:player_season, :def_players).where(player_seasons: {season_id: @season.id}).pluck("def_players.id")}).order(Arel.sql("RANDOM()")).first
          end
          userClub = User.getClub(user.id, @season.id)
          @newHirePlayer = @availablePlayers

          ## Define PLayer Salary based on Season Selection
          pSalary = DefPlayer.getSeasonInitialSalary(@season, @newHirePlayer)

          ## Find / Create new SeasonPlayer
          sPlayer = PlayerSeason.where(def_player_id: @newHirePlayer.id, season_id: @season.id).first_or_create do |sP|
            sP.details = {
              salary: pSalary
            }
          end

          ## Insert new Player into Club Player table
          newHire = ClubPlayer.new
          newHire.club_id = userClub.id
          newHire.player_season_id = sPlayer.id
          newHire.save!

          ## Create new entry into Club Player Salary logs
          PlayerSeasonFinance.create(player_season_id: sPlayer.id, operation: "initial_salary", value: pSalary, source: Club.find(userClub.id))
        end
      end
    end

    respond_to do |format|
      if @season.update(
        preferences = {
          saction_players_choosing: 2
        }
      )

        DefPlayerNotification.with(
          season: @season,
          league: @season.league_id,
          icon: "user-add",
          type: "stop_players_raffle",
          push: true,
          push_message: "#{t(".wnotify_subject", season: @season.name)}||#{t(".wnotify_text")}"
        ).deliver_later(User.joins(:user_seasons).where("user_seasons.season_id = ? AND users.preferences -> 'fake' IS NULL", @season.id))

        flash.now["success"] = t(".success")
        format.html { redirect_to manager_seasons_path, notice: t(".success") }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def user_players
    @season = Season.find_by_hashid(params[:id])
    @user = User.friendly.find(params[:user])

    @teamPlayers = User.getTeamPlayers(@user.id, @season.id)
  end

  def settings
    @season = Season.find_by_hashid(params[:id])
    @awards = Award.where(league_id: @league.id, status: true)
    @award_result_type = helpers.award_result_types
  end

  def create
    @season = Season.new
    @season.name = season_params[:name]
    @season.start = DateTime.parse(season_params[:start_date])
    @season.duration = season_params[:time]
    @season.league_id = current_user.preferences["active_league"]
    @season.advertisement = season_params[:advertisement]
    @season.preferences = {
      min_players: season_params[:min_players],
      max_players: season_params[:max_players],
      allow_fire_player: season_params[:allow_fire_player],
      change_player_out_of_window: season_params[:change_player_out_of_window],
      enable_players_loan: season_params[:enable_players_loan],
      enable_players_exchange: season_params[:enable_players_exchange],
      enable_player_steal: season_params[:enable_player_steal],
      max_steals_same_player: season_params[:max_steals_same_player],
      max_steals_per_user: season_params[:max_steals_per_user],
      max_stealed_players: season_params[:max_stealed_players],
      steal_window_start: season_params[:steal_window_start],
      steal_window_end: season_params[:steal_window_end],
      add_value_after_steal: season_params[:add_value_after_steal],
      allow_money_transfer: season_params[:allow_money_transfer],
      default_player_earnings: season_params[:default_player_earnings],
      default_player_earnings_fixed: season_params[:default_player_earnings_fixed],
      allow_increase_earnings: season_params[:allow_increase_earnings],
      allow_decrease_earnings: season_params[:allow_decrease_earnings],
      allow_negative_funds: season_params[:allow_negative_funds],
      club_default_earning: season_params[:club_default_earning],
      club_max_total_wage: season_params[:club_max_total_wage],
      operation_tax: season_params[:operation_tax],
      player_value_earning_relation: season_params[:player_value_earning_relation],
      fire_tax: season_params[:fire_tax],
      fire_tax_fixed: season_params[:fire_tax_fixed],
      default_mininum_operation: season_params[:default_mininum_operation],
      time_game_confirmation: season_params[:time_game_confirmation],
      raffle_low_over: season_params[:raffle_low_over],
      raffle_high_over: season_params[:raffle_high_over],
      raffle_switches: season_params[:raffle_switches],
      raffle_remaining: season_params[:raffle_remaining],
      saction_players_choosing: 0,
      saction_transfer_window: 0,
      saction_player_steal: 0,
      saction_change_wage: 0,
      saction_clubs_choosing: 0,
      award_firstplace: season_params[:firstplace],
      award_secondplace: season_params[:secondplace],
      award_thirdplace: season_params[:thirdplace],
      award_fourthtplace: season_params[:fourthplace],
      award_goaler: season_params[:goaler],
      award_assister: season_params[:assister],
      award_fairplay: season_params[:fairplay]
    }
    @season.status = 0

    respond_to do |format|
      if @season.save!
        User.joins(:user_leagues).where("league_id = ? AND status = ?", @league.id, true).each do |user|
          uSeason = UserSeason.create(user_id: user.id, season_id: @season.id)
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

        flash.now["success"] = t(".success")
        format.html { redirect_to manager_seasons_path, notice: t(".success") }
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
      min_players: season_params[:min_players],
      max_players: season_params[:max_players],
      allow_fire_player: season_params[:allow_fire_player],
      change_player_out_of_window: season_params[:change_player_out_of_window],
      enable_players_loan: season_params[:enable_players_loan],
      enable_players_exchange: season_params[:enable_players_exchange],
      enable_player_steal: season_params[:enable_player_steal],
      max_steals_same_player: season_params[:max_steals_same_player],
      max_steals_per_user: season_params[:max_steals_per_user],
      max_stealed_players: season_params[:max_stealed_players],
      steal_window_start: season_params[:steal_window_start],
      steal_window_end: season_params[:steal_window_end],
      add_value_after_steal: season_params[:add_value_after_steal],
      allow_money_transfer: season_params[:allow_money_transfer],
      default_player_earnings: season_params[:default_player_earnings],
      default_player_earnings_fixed: season_params[:default_player_earnings_fixed],
      allow_increase_earnings: season_params[:allow_increase_earnings],
      allow_decrease_earnings: season_params[:allow_decrease_earnings],
      allow_negative_funds: season_params[:allow_negative_funds],
      club_default_earning: season_params[:club_default_earning],
      club_max_total_wage: season_params[:club_max_total_wage],
      operation_tax: season_params[:operation_tax],
      player_value_earning_relation: season_params[:player_value_earning_relation],
      fire_tax: season_params[:fire_tax],
      fire_tax_fixed: season_params[:fire_tax_fixed],
      default_mininum_operation: season_params[:default_mininum_operation],
      time_game_confirmation: season_params[:time_game_confirmation],
      raffle_low_over: season_params[:raffle_low_over],
      raffle_high_over: season_params[:raffle_high_over],
      raffle_switches: season_params[:raffle_switches],
      raffle_remaining: season_params[:raffle_remaining],
      saction_players_choosing: @season.saction_players_choosing,
      saction_transfer_window: @season.saction_transfer_window,
      saction_player_steal: @season.saction_player_steal,
      saction_change_wage: @season.saction_change_wage,
      saction_clubs_choosing: @season.saction_clubs_choosing,
      award_firstplace: season_params[:firstplace],
      award_secondplace: season_params[:secondplace],
      award_thirdplace: season_params[:thirdplace],
      award_fourthtplace: season_params[:fourthplace],
      award_goaler: season_params[:goaler],
      award_assister: season_params[:assister],
      award_fairplay: season_params[:fairplay]
    }

    respond_to do |format|
      if @season.save!
        flash.now["success"] = t(".success")
        format.html { redirect_to manager_seasons_path, notice: t(".success") }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def details
    # Get Season
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

    ## Seasons
    @seasons = Season.where(league_id: @league.id).where.not(id: @season.id).order(updated_at: :desc)
  end

  def end_season
    @season = Season.find_by_hashid(params[:id])
  end

  def end_season_
    @season = Season.find_by_hashid(params[:id])
    oActions = Championship.where(season_id: @season.id).where("status < 100").size
    if oActions > 0
      flash.now[:error] = "Existem Campeonatos em aberto!! Encerre-os antes de tentar Finalizar uma Temporada!"
      respond_to do |format|
        format.turbo_stream
      end
    else
      pay_wages = params[:season_end].has_key?(:pay_wages) ? true : false
      clear_club_balance = params[:season_end].has_key?(:clear_club_balance) ? true : false

      ##
      # Now that we have options, we go through each club and
      # players from the season and apply each selected option
      @season.user_seasons.each do |uSeason|
        ## Get uSeason Club
        club = uSeason.clubs.first

        ## Get Club Players
        players = User.getTeamPlayers(uSeason.user_id, @season.id).includes(player_season: [player: :player_position])

        ## Go through each player
        players.each do |cPlayer|
          ## Check if Pay Wage was selected
          if pay_wages
            ## Ok, selected, now we need to debit players salary from club
            wage = cPlayer.player_season.details["salary"].to_i

            ## Debit player wage from Club Balance
            ClubFinance.create(club_id: club.id, operation: "pay_wage", value: wage, source: cPlayer.player_season)
          end

          ## Add new entry to Player Transactions
          PlayerTransaction.addNew(cPlayer.player_season, club, nil, "dismiss", 0)

          ## Remove entry in ClubPlayers table
          cPlayer.destroy!
        end

        ## If Club Balance Reset was selected
        if clear_club_balance
          ## Create 1st entry into Club Finance model
          ClubFinance.create(club_id: club.id, operation: "clear_club_balance", value: 0, balance: 0, source: @season)
        end
      end

      ## End Season and Notify Users
      @season.status = 2
      if @season.save
        @season.update(
          preferences = {
            saction_players_choosing: 2,
            saction_transfer_window: 2,
            saction_player_steal: 2
          }
        )

        ## WebPush Notify Season Users about change
        Push::Notify.group_notify(
          "season",
          current_user.id,
          @season,
          "end_season",
          "Temporada :: #{@season.name} :: Encerrada!",
          true,
          @season.id
        )

        flash[:success] = "Temporada encerrada com sucesso!"
      else
        flash[:error] = "Erro encerrando a Temporada!"
      end
      respond_to do |format|
        format.js
      end
    end
  end

  def start_season
    @season = Season.find_by_hashid(params[:id])
    if @season.status == 1
      flash.now[:error] = "Temporada já em Andamento!"
    else
      respond_to do |format|
        if @season.update(status: 1)

          SeasonNotification.with(
            season: @season,
            league: @season.league_id,
            icon: "stack",
            type: "start",
            push: true,
            push_message: "#{t(".wnotify_subject", season: @season.name)}||#{t(".wnotify_text")}"
          ).deliver_later(current_user)

          SeasonNotification.with(
            season: @season,
            league: @season.league_id,
            icon: "stack",
            type: "start",
            push: true,
            push_message: "#{t(".wnotify_subject", season: @season.name)}||#{t(".wnotify_text")}"
          ).deliver_later(User.joins(:user_seasons).where("user_seasons.season_id = ? AND users.preferences -> 'fake' IS NULL", @season.id))

          format.turbo_stream { render "sactions_update" }
          format.html { redirect_to manager_seasons_details_path(@season.hashid), notice: t(".success") }
        else
          flash.now["error"] = t(".error")
          format.html { render :edit, status: :unprocessable_entity }
        end
      end
    end
  end

  def start_clubs_choosing
    @season = Season.find_by_hashid(params[:id])
    respond_to do |format|
      if @season.update(preferences = {saction_clubs_choosing: 1})
        SeasonNotification.with(
          season: @season,
          league: @season.league_id,
          icon: "stack",
          type: "start_clubs_choosing",
          push: false,
          push_message: t(".wnotify_subject", season: @season.name)
        ).deliver_later(current_user)

        SeasonNotification.with(
          season: @season,
          league: @season.league_id,
          icon: "stack",
          type: "start_clubs_choosing_user",
          push: true,
          push_message: "#{t(".wnotify_subject", season: @season.name)}||#{t(".wnotify_text")}"
        ).deliver_later(User.joins(:user_seasons).where("user_seasons.season_id = ? AND users.preferences -> 'fake' IS NULL", @season.id))

        flash.now[:success] = t(".success")
        format.turbo_stream { render "sactions_update" }
        format.html { redirect_to manager_seasons_details_path(@season.hashid), notice: t(".success") }
      else
        flash.now["error"] = t(".error")
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def stop_clubs_choosing
    @season = Season.find_by_hashid(params[:id])
    platform = @season.league.platform
    orderedChoosingQueue = UserSeason.where(season_id: @season.id).pluck(:user_id)
    orderedChoosingQueue.each do |cQueue|
      userClub = User.getClub(cQueue, @season.id)
      user = User.find(cQueue)
      userSeason = UserSeason.where(user_id: user.id, season_id: @season.id).first
      if userClub.nil?
        newClub = DefTeam.where(nation: false, active: true).where("platforms ILIKE '%#{platform}%'").where.not(def_teams: {id: Club.joins(:user_season).where(user_seasons: {season_id: @season.id})}).order(Arel.sql("RANDOM()")).first

        tFormations = helpers.team_formations
        formation_pos = []
        tFormations[0][:pos].each do |tF|
          formation_pos << {pos: tF, player: ""}
        end
        club = Club.new
        club.def_team_id = newClub.id
        club.user_season_id = userSeason.id
        club.details = {
          team_formation: 0,
          formation_pos: formation_pos
        }
        club.save!

        ClubFinance.create(club_id: club.id, operation: "initial_funds", value: @season.preferences["club_default_earning"].gsub(/[^\d.]/, "").to_i, balance: @season.preferences["club_default_earning"].gsub(/[^\d.]/, "").to_i, source: @season)

        SeasonNotification.with(
          season: @season,
          league: @season.league_id,
          icon: "stack",
          push: true,
          push_type: "user",
          push_message: "#{t(".wnotify_subject", season: @season.name)}||#{t(".wnotify_text")}",
          type: "club_choosed"
        ).deliver_later(user)
      end
    end

    SeasonNotification.with(
      season: @season,
      league: @season.league_id,
      icon: "stack",
      type: "stop_clubs_choosing",
      push: false,
      push_message: t(".wnotify_subject", season: @season.name)
    ).deliver_later(current_user)

    respond_to do |format|
      if @season.update(preferences = {saction_clubs_choosing: 2})
        flash.now[:success] = "Clubes Definidos para esta Temporada! Prossiga agora com a Definição do Plantel"
        format.turbo_stream { render "sactions_update" }
        format.html { redirect_to manager_seasons_details_path(@season.hashid), notice: t(".success") }
      else
        flash.now["error"] = t(".error")
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def users
    @season = Season.find_by_hashid(params[:id])
  end

  def destroy
    @season = Season.find_by_hashid(params[:id])
    respond_to do |format|
      if @season.status == 1
        format.turbo_stream { flash["error"] = t(".in_progress") }
        format.html { render :index, status: :unprocessable_entity, notice: t(".in_progress") }
      else
        if @season.destroy!
          format.html { redirect_to manager_seasons_path, notice: t(".success") }
        else
          format.html { render :index, status: :unprocessable_entity }
        end
      end
    end
  end

  private

  def set_local_vars
    if current_user.role == "manager"
      @league = League.find(session[:league])
    end
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
    params.require(:awards).permit(award: {})
  end

  def user_params
    params.permit(users: [])
  end
end
