class ChampionshipsController < ApplicationController
  before_action :set_controller_vars
  before_action :set_championship, only: [:details, :games]
  breadcrumb "dashboard", :root_path, match: :exact, turbo: "false"
  breadcrumb "championships.main", :championships_path, match: :exact, frame: "main_frame"

  def index
    if @season
      @pagy, @championships = pagy(Championship.where(season_id: @season.id).order(updated_at: :desc), items: 6)
      @seasons = Season.where(league_id: session[:league]).order(updated_at: :desc)
    end
  end

  def set_championship
    @championship = Championship.find_by_hashid(params[:id])
  end

  def details
    breadcrumb @championship.name, :championship_details_path
    # if @championship.status == 100
    #   @cPositions = ChampionshipPosition.where(championship_id: @championship.id).order(position: :asc)
    # end

    @goalers = Championship.getGoalers(@championship, 5)
    @assists = Championship.getAssisters(@championship, 5)
    @fairplay = Championship.getFairPlay(@championship, 5)
    @bestplayer = Championship.getBestPlayer(@championship, 5)
    @lGames = Game.where(championship_id: @championship.id, status: 3).order(updated_at: :desc).limit(5)
    @user_season = UserSeason.where(season_id: @season.id).includes(:user)
  end

  def games
    # @allGames = params[:games] == "all" ? true : false
    # if @allGames
    #     @games = Game.includes(:championship, :game_cards, club_games: [:club, player_season: [player: :player_position]]).where(championship_id: @championship.id).order(created_at: :asc).page(params[:page]).per(10)
    # else
    breadcrumb @championship.name, :championship_details_path
    @pagy, @games = pagy(Game.includes(:championship, club_games: [:club, player_season: [def_player: :def_player_position]]).where(championship_id: @championship.id).order(created_at: :asc), items: 4)
  end

  def set_controller_vars
    @season = Season.find(session[:season])
  end
end