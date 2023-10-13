class SquadController < ApplicationController
  before_action :set_controller_vars
  breadcrumb "dashboard", :root_path, match: :exact, turbo: "false"
  breadcrumb "squad.main", :squad_path, match: :exact, frame: "main_frame"

  def index
    @club_players = User.getTeamPlayers(current_user.id, @season.id).includes(:player_season)
    @team_strength = Club.getTeamStrength(current_user.id, @season.id)
    @team_overall_avg = @team_strength == 0 ? 0 : @team_strength/@club_players.size
  end

  def set_controller_vars
    @season = Season.find(session[:season])
    @club = User.getClub(current_user.id, @season.id)
  end
end