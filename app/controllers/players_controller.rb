class PlayersController < ApplicationController

  def details
    @defPlayer = DefPlayer.includes(:def_player_position).find_by(slug: params[:id], platform: params[:platform])
    @positions = helpers.getVisualPlayerPositions(@defPlayer)
  end

end



