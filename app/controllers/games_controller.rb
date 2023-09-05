class GamesController < ApplicationController 
  before_action :set_game, only: [:start, :results, :update_card, :add_goal, :remove_goal, :add_card, :remove_card]

  def set_game
    @game = Game.find_by_hashid(params[:id])
  end

  def start
    update_card(AppServices::Games::Start.call(@game, current_user, {club: session[:userClub]}), t(".success"))
  end

  def results
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

  def remove_goal
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

  def update_goal_card
    respond_to do |format|
      format.turbo_stream { render "games/actions/update_goal_card" }
    end
  end

  def update_card(resolution, success_message)
    respond_to do |format|
      if resolution.success?
        GameCardJob.perform_later(@game, session[:pdbprefix], current_user)

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
    helpers.players_suspended(game.championship.hashid, game.hashid)
  end

end