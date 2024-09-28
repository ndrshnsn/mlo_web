class StealJob < ApplicationJob 
  queue_as :trades

  def perform(pdbprefix, season_id, player_transaction, user)
    club_from = player_transaction.from_club
    club_to = player_transaction.to_club
    player_value = PlayerSeason.getPlayerPass(player_transaction.player_season, Season.find(season_id)).format

    Turbo::StreamsChannel.broadcast_replace_to(
      "steal_window_#{season_id}",
      partial: "steals/info",
      locals: { club: club_from, season: Season.find(season_id) },
      target: "info_#{club_from.id}")

    Turbo::StreamsChannel.broadcast_replace_to(
      "steal_window_#{season_id}",
      partial: "steals/info",
      locals: { club: club_to, season: Season.find(season_id) },
      target: "info_#{club_to.id}")

    Turbo::StreamsChannel.broadcast_render_later_to(
      "steal_window_#{season_id}",
      partial: "steals/stealed",
      locals: {
        player_season: player_transaction.player_season,
        player: player_transaction.player_season.def_player,
        player_value: player_value,
        session_pdbprefix: pdbprefix,
        user: user,
        season: Season.find(season_id),
      }
    )
  end
end
