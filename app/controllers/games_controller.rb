class GamesController < ApplicationController 
  before_action :set_game, only: [:start, :results, :update_card, :add_goal]

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
    if request.get?
      @side = params[:side]
      club_owner = @side == "home" ? @game.home.user_season.user.id : @game.visitor.user_season.user.id
      @players = User.getTeamPlayers(club_owner, session[:season]).includes(player_season: [def_player: :def_player_position])
      @suspended_players = helpers.players_suspended(@game.championship.hashid, params[:id])
      render "games/actions/add_goal"
    elsif request.patch?
      Rails.cache.write("tgoals_#{@game.hashid}", params[:add_goal][:selection])


      logger.info "----- #{Rails.cache.read("tgoals_#{@game.hashid}")}"
      
    end
  end

  def add_card
  end

  def update_card(resolution, success_message)
    respond_to do |format|
      if resolution.success?
        GameCardJob.perform_later(@game, session[:pdbprefix], current_user)

        flash.now["success"] = success_message
        format.turbo_stream { render "games/actions/update_card" }
        format.html { redirect_to manager_championships_path, notice: success_message }
      else
        flash.now["error"] = I18n.t("defaults.errors.games.#{resolution.error}")
        format.turbo_stream { render "games/actions/update_card" }
        format.html { render :details, status: :unprocessable_entity }
      end
    end
  end
end