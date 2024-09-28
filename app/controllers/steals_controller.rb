class StealsController < ApplicationController
  before_action :set_controller_vars
  breadcrumb "dashboard", :root_path, match: :exact, turbo: "false"
  breadcrumb "steals.main", :steals_path, match: :exact, frame: "main_frame"

  def index
    worker = Sidekiq::Cron::Job.find("steal_window_#{@season.id}")
    @next_enqueue = Time.parse(worker.enqueue_args[2]) + @season.preferences["steal_window_end"].hour if worker

    @clubs = Club.joins(:user_season).includes(:def_team, user_season: :user).where(user_seasons: { season_id: @season.id } )

    @prev_steals = PlayerTransaction.joins(:player_season).where(player_transactions: {transfer_mode: 'steal'}, player_seasons: {season_id: @season.id}).limit(15).order(created_at: :desc)
  end

  def steal_player
    steal_resolution = AppServices::Steal.call(@season, current_user, session[:userClub], steal_player_params[:id], current_user.id)
    respond_to do |format|
      if steal_resolution.success?
        flash.now["success"] = I18n.t("steals.success.#{steal_resolution.success}")
      else
        flash.now["error"] = I18n.t("steals.errors.#{steal_resolution.error}")
      end
      format.turbo_stream
    end
  end

  def get_proc_dt
    render json: User::StealsDatatable.new(view_context)
  end

  def set_controller_vars
    @season = Season.find(session[:season])
    @club = User.getClub(current_user.id, @season.id)
  end

  def steal_player_params
    params.permit(:id)
  end
end
