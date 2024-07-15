class Trades::BuyJob < ApplicationJob
  queue_as :trades

  def perform(pdbprefix, season_id, player)
    player_value = PlayerSeason.getPlayerPass(player, Season.find(season_id))
    Turbo::StreamsChannel.broadcast_render_later_to(
      "trades_buy_#{season_id}",
      partial: "trades/buy/hired",
      locals: {
        pSeason: player,
        player: player.def_player,
        playerValue: player_value,
        session_pdbprefix: pdbprefix
      }
    )
  end
end
