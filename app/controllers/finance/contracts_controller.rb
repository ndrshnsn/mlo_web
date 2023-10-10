class Finance::ContractsController < ApplicationController
  before_action :set_controller_vars
  breadcrumb "dashboard", :root_path, match: :exact, turbo: "false"
  breadcrumb "finance.main", :trades_path, match: :exact, frame: "main_frame"
  breadcrumb "finance.contracts.main", :trades_buy_path, match: :exact, frame: "main_frame"

  def index
    @club_players = User.getTeamPlayers(current_user.id, @season.id).includes(:player_season)
  end

  def fire
    player = ClubPlayer.find(params[:id])
    show_step(AppServices::Trades::Fire.call(@club, @season, player), t(".success"))
  end

  def show_step(resolution, success_message)
    @club_players = User.getTeamPlayers(current_user.id, @season.id).includes(:player_season)
    respond_to do |format|
      if resolution.success?
        flash.now["success"] = success_message
        format.html { redirect_to trades_buy_path, notice: success_message }
      else
        flash.now["error"] = I18n.t("defaults.errors.finance.contracts.#{resolution.error}")
        format.html { render :details, status: :unprocessable_entity }
      end
      format.turbo_stream { render "show_step" }
    end
  end

  def set_controller_vars
    @season = Season.find(session[:season])
    @club = User.getClub(current_user.id, @season.id)
  end
end
