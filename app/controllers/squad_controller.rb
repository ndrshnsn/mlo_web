class SquadController < ApplicationController
  before_action :set_controller_vars
  breadcrumb "dashboard", :root_path, match: :exact, turbo: "false"
  breadcrumb "squad.main", :squad_path, match: :exact, frame: "main_frame"

  def index
    @club_players = User.getTeamPlayers(current_user.id, @season.id).includes(:player_season)
    @team_strength = Club.getTeamStrength(current_user.id, @season.id)
    @team_overall_avg = @team_strength == 0 ? 0 : @team_strength/@club_players.size
  end

	def set_formation
		selFormation = helpers.team_formations[params[:formation_selection].to_i]
    formation_pos = []
    selFormation[:pos].each do |tF|
      formation_pos << { pos: tF, player: ''}
    end

		update_tactics if @club.update(details = {
			team_formation: params[:formation_selection],
			formation_pos: formation_pos
		})
	end

  def position_select
		@players = User.getTeamPlayers(current_user.id, @season.id).includes(:player_season)
		@position = params[:position]
	end

	def add_player_to_gp
		formation_pos = @club.details["formation_pos"]
		hashKey = formation_pos.find { |h| h['pos'] ==  params[:formation_position] }
		hashKey["player"] = params[:formation_selection]

		update_tactics if @club.update(
			details = {
				formation_pos: formation_pos
			}
		)
	end

	def del_player_from_gp
		formation_pos = @club.details["formation_pos"]
		hashKey = formation_pos.find { |h| h['player'] ==  params[:formation_selection] }
		hashKey["player"] = ""

		update_tactics if @club.update(
			details = {
				formation_pos: formation_pos
			}
		)
	end

  def update_tactics
    respond_to do |format|
      @club_players = User.getTeamPlayers(current_user.id, @season.id).includes(:player_season)
      flash.now["success"] = t(".success")
      format.turbo_stream { render "squad/update_tactics" }
    end
  end

  def set_controller_vars
    @season = Season.find(session[:season])
    @club = User.getClub(current_user.id, @season.id)
  end
end