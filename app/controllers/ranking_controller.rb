class RankingController < ApplicationController
  before_action :set_controller_vars
  breadcrumb "dashboard", :root_path, match: :exact, turbo: "false"
  breadcrumb "ranking.main", :ranking_path, match: :exact, frame: "main_frame"

  def index
    ## List of Seasons for Select
    @seasons = Season.joins(:user_seasons).where(user_seasons: { user_id: current_user.id })

    if @season
      @ranking = Season.getRanking(@season)
    end
  end

  def history
    @history_info = Ranking.eager_load(:championship_award, :season_award, :game).where(season_id: @season.id, club_id: params[:club]).order(id: :desc).limit(30)
  end

  def set_controller_vars
    @season = Season.find(session[:season])
  end
end