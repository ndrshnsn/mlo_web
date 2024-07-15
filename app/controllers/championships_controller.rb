class ChampionshipsController < ApplicationController
  before_action :set_controller_vars
  before_action :set_championship, only: [:details, :games, :goalers, :fairplay, :bestofmatch, :standing]
  before_action :set_crumb, only: [:details, :goalers, :assisters]
  breadcrumb "dashboard", :root_path, match: :exact, turbo: "false"
  breadcrumb "championships.main", :championships_path, match: :exact, frame: "main_frame"

  def index
    if @season
      @pagy, @championships = pagy(Championship.where(season_id: @season.id).order(updated_at: :desc), items: 6)
      @seasons = Season.where(league_id: session[:league]).order(updated_at: :desc)
    end
  end

  def set_championship
    @championship = Championship.friendly.find(params[:id])
  end

  def set_crumb
    set_championship
    breadcrumb @championship.name, :championship_details_path
  end

  def details
    if @championship.status == 100
      @cPositions = ChampionshipPosition.where(championship_id: @championship.id).order(position: :asc)
    end

    @assists = Championship.getAssisters(@championship, 5)
    @fairplay = Championship.getFairPlay(@championship, 5)
    @bestplayer = Championship.getBestPlayer(@championship, 5)
    @lGames = Game.where(championship_id: @championship.id, status: 3).order(updated_at: :desc).limit(5)
    @user_season = UserSeason.where(season_id: @season.id).includes(:user)
    @next_games = Game.where(championship_id: @championship.id, status: 0).order(gsequence: :asc).limit(2)
  end

  def standing
    @standing = Championship.get_standing(@championship, nil)
    render "championships/details/league/_standing"
  end

  def goalers
    @pagy, @goalers = pagy_array(Championship.getGoalers(@championship), items: 15)
    render "championships/details/_goalers"
  end

  def assisters
    @pagy, @assisters = pagy_array(Championship.getAssisters(@championship), items: 15)
    render "championships/details/_assisters"
  end

  def fairplay
    @pagy, @cards = pagy_array(Championship.getFairPlay(@championship), items: 15)
    render "championships/details/_fairplay"
  end

  def bestofmatch
    @pagy, @bestofmatch = pagy_array(Championship.getBestPlayer(@championship), items: 15)
    render "championships/details/_bestofmatch"
  end

  def games
    breadcrumb @championship.name, :championship_details_path
    @club_championship = ClubChampionship.find_by(championship_id: @championship.id, club_id: session[:userClub])
    championship_games = Game.includes(:championship, club_games: [:club, player_season: [def_player: :def_player_position]]).where(championship_id: @championship.id)
    if @club_championship
      session[:show_all_games] |= false
      if request.patch?
        session[:show_all_games] = params[:championship][:show_all_games] == "1" ? true : false
      end
      championship_games = championship_games.where("games.home_id = ? OR games.visitor_id = ?", session[:userClub], session[:userClub]) if session[:show_all_games] == false
    end
    @pagy, @games = pagy(championship_games.order(created_at: :asc), items: 4)
  end

  def set_controller_vars
    @season = Season.find(session[:season])
  end
end