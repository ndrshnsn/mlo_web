class Myclub::ManagementController < ApplicationController
  before_action :set_local_vars
  breadcrumb "dashboard", :root_path, match: :exact
  breadcrumb "myclub.main", :myclub_management_path, match: :exact
  breadcrumb "myclub.management.main", :myclub_management_path, match: :exact

  def index
  end

  def get_cteams
    if !@userClub
      @userClub = Club.new
    end

    @teams = DefTeam.where(active: true).where("platforms LIKE ?", "%#{@league.platform}%").order(name: :asc)
    @disabled_teams = Club.joins(:user_season).where(user_season: {season_id: @season.id}).pluck(:def_team_id)
  end

  def show_team_details
    @team = DefTeam.find(params[:selected_team])
  end

  def select_club
    @team = DefTeam.find(params[:teams_selection])
    @userSeason = UserSeason.where(user_id: current_user.id, season_id: @season.id).first

    if request.post?
      tFormations = helpers.team_formations
      formation_pos = []
      tFormations[0][:pos].each do |tF|
        formation_pos << {pos: tF, player: ""}
      end

      @club = Club.new
      @club.def_team_id = @team.id
      @club.user_season_id = @userSeason.id
      @club.details = {
        team_formation: 0,
        formation_pos: formation_pos
      }
    end

    if request.patch?
      @userClub.reload
      @club = @userClub
      @club.def_team_id = @team.id
    end

    respond_to do |format|
      if @club.save!
        session[:userClub] = @club.id
        # if request.post?
        #   ClubFinance.create(club_id: @club.id, operation: "initial_funds", value: @season.preferences["club_default_earning"].gsub(/[^\d.]/, "").to_i, balance: @season.preferences["club_default_earning"].gsub(/[^\d.]/, "").to_i, source: @season)
        # end

        SeasonNotification.with(
          season: @season,
          league: @season.league_id,
          icon: "stack",
          push: true,
          push_type: "user",
          push_message: "#{t(".wnotify_subject", season: @season.name)}||#{t(".wnotify_text")}",
          type: "club_choosed"
        ).deliver_later(current_user)

        flash.now["success"] = t(".success")
        format.html { redirect_to myclub_management_path, notice: t(".success") }
        format.turbo_stream
      else
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_local_vars
    @userClub = Club.find(session[:userClub]) if session[:userClub]
    @league = League.find(session[:league])
    @season = Season.find(session[:season])
  end
end
