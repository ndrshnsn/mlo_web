class Trades::FireJob < ApplicationJob
  queue_as :trades

  def perform(pdbprefix, season_id, player)
    player_value = PlayerSeason.getPlayerPass(player, Season.find(season_id)).format
    Turbo::StreamsChannel.broadcast_render_later_to(
      "trades_buy_#{season_id}",
      partial: "trades/buy/fired",
      locals: {
        pSeason: player,
        player: player.def_player,
        playerValue: player_value,
        session_pdbprefix: pdbprefix,
        season: Season.find(season_id)
      }
    )
  end
end
