class ClubsController < ApplicationController
  before_action :set_controller_vars
  breadcrumb "dashboard", :root_path, match: :exact, turbo: "false"
  breadcrumb "clubs.main", :clubs_path, match: :exact, frame: "main_frame"

  def index
    @clubs = Season.getClubs(@season.id).where.not(id: User.getClub(current_user.id, @season.id))
  end

  def summary
    @club = Club.includes([user_season: :user], :def_team).where(user_seasons: { season_id: @season.id }, def_teams: { slug: params[:id]}).first
    humanized_club = helpers.stringHuman(DefTeam.getTranslation(@club.def_team.name)[0])
    breadcrumb humanized_club, club_summary_path(@club.def_team.friendly_id), match: :exact
    @players = Club.get_players(@club.id, @season.preferences["raffle_platform"])
  end

  def player_details
    @defPlayer = DefPlayer.includes(:def_player_position).friendly.find(params[:player_id])
    @positions = helpers.getVisualPlayerPositions(@defPlayer)
  end

  def set_controller_vars
    @season = Season.find(session[:season])
  end
end