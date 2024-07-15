class GamesController < ApplicationController 
  before_action :set_game, only: [:start, :results, :update_card, :add_goal, :add_card, :remove_goal_card, :update, :confirm]

  def set_game
    @game = Game.find(params[:id])
  end

  def start
    update_card(AppServices::Games::Start.call(@game, current_user, {club: session[:userClub]}), t(".success"))
  end

  def results
    if @game.championship.preferences["match_best_player"] == "on"
      @players_home = get_card_players(@game.home.user_season.user.id)
      @players_visitor = get_card_players(@game.visitor.user_season.user.id)
      @suspended_players = get_suspended_players(@game)
    end

    if Championship.translate_phase(@game.phase)[2]
      phase_games = Game.where(championship_id: @game.championship_id).where("phase = ?", @game.phase).where("home_id = ? OR visitor_id = ?", @game.home_id, @game.home_id)

      if phase_games.count == 1
        @penalties = true
      elsif phase_games.count == 2
        @previous_game = phase_games.where(games: { status: 3 }).first
        @result_criterion = @game.championship.preferences["league_criterion"]
        @penalties = true if @previous_game && @previous_game.hscore == @previous_game.vscore
      end
    end

    if @game.eresults_id == nil || current_user.manager?
      if current_user.manager?
        @game.update(
          hsaccepted: true,
          vsaccepted: true,
          hfaccepted: true,
          vfaccepted: true,
          mresult: true
        )
      else                    
        @game.update!(eresults_id: session[:userClub])
      end
      GameCardJob.perform_later(@game, session[:pdbprefix], session[:season], current_user)
    end
    render "games/actions/results"
  end

  def add_goal
    @side = params[:side]
    if request.get?
      club_owner = @side == "home" ? @game.home.user_season.user.id : @game.visitor.user_season.user.id
      @players = get_card_players(club_owner)
      @suspended_players = get_suspended_players(@game)
      render "games/actions/add_goal"
    else
      @actor = PlayerSeason.find(params[:add_goal][:selection])
      @assister = params[:add_assist][:selection] != "-" ? PlayerSeason.find(params[:add_assist][:selection]) : "-"
      @change_result = "add_goal"
      @card_rand = rand(99999)
      update_goal_card
    end
  end

  def remove_goal_card
    @card_id = params[:card]
    respond_to do |format|
      format.turbo_stream { render "games/actions/remove_goal_card" }
    end
  end

  def add_card
    @side = params[:side]
    if request.get?
      club_owner = @side == "home" ? @game.home.user_season.user.id : @game.visitor.user_season.user.id
      @players = get_card_players(club_owner)
      @suspended_players = get_suspended_players(@game)
      render "games/actions/add_card"
    else
      @actor = PlayerSeason.find(params[:add_card][:selection])
      @type = params[:game_card_type_selection]
      @change_result = "add_card"
      @card_rand = rand(99999)
      update_goal_card      
    end
  end

  def confirm
    update_card(AppServices::Games::Confirm.call(@game, current_user, session[:userClub]), t(".success"))
  end

  def update
    update_card(AppServices::Games::Update.call(@game, current_user, {data: params, club: session[:userClub]}), t(".success"))
  end

  def update_goal_card
    respond_to do |format|
      format.turbo_stream { render "games/actions/update_goal_card" }
    end
  end

  def update_card(resolution, success_message)
    respond_to do |format|
      if resolution.success?
        GameCardJob.perform_later(@game, session[:pdbprefix], session[:season], current_user)
        flash.now["success"] = success_message
        format.turbo_stream { render "games/actions/update_game" }
        format.html { redirect_to manager_championships_path, notice: success_message }
      else
        flash.now["error"] = I18n.t("defaults.errors.games.#{resolution.error}")
        format.turbo_stream { render "games/actions/update_game" }
        format.html { render :details, status: :unprocessable_entity }
      end
    end
  end

  private

  def get_card_players(owner)
    User.getTeamPlayers(owner, session[:season]).includes(player_season: [def_player: :def_player_position])
  end

  def get_suspended_players(game)
    helpers.players_suspended(game.championship_id, game.id, session[:season])
  end

end