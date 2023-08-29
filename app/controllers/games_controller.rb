class GamesController < ApplicationController 
  before_action :set_game, only: [:start, :update_card]

  def set_game
    @game = Game.find_by_hashid(params[:id])
  end

  def start
    update_card(AppServices::Games::Start.call(@game, current_user, {club: session[:userClub]}), t(".success"))
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