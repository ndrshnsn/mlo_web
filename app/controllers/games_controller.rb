class GamesController < ApplicationController 
  before_action :set_game, only: [:start]

  def set_game
    @game = Game.find_by_hashid(params[:id])
  end

  def start
    update_card(AppServices::Games::Start.call(@game), t(".success"))
  end

  def update_card
    respond_to do |format|
      # if resolution.success?
      #   # details
      #   flash.now["success"] = success_message
      #   format.turbo_stream { render "show_step" }
      #   format.html { redirect_to manager_championships_path, notice: success_message }
      # else
      
      format.turbo_stream { render "games/actions/update_card" }
    end
  end
end