class GameCardJob < ApplicationJob
  queue_as :games

  def perform(game, pdbprefix, session, user)
    home = game.home.user_season.user
    visitor = game.visitor.user_season.user
    remaining_users = Club.joins(:championships).where(championships: { id: game.championship_id }).where.not(id: [game.home, game.visitor])

    Turbo::StreamsChannel.broadcast_replace_to(
      "games_#{home.id}",
      partial: "games/card",
      locals: { game: game, session_pdbprefix: pdbprefix, session_season: session, current_user_id: home.id },
      target: "game_#{game.hashid}")

    Turbo::StreamsChannel.broadcast_replace_to(
      "games_#{visitor.id}",
      partial: "games/card",
      locals: { game: game, session_pdbprefix: pdbprefix, session_season: session, current_user_id: visitor.id },
      target: "game_#{game.hashid}")

    remaining_users.each do |remaining_user|
      Turbo::StreamsChannel.broadcast_replace_to(
        "games_#{remaining_user.user_season.user.id}",
        partial: "games/card",
        locals: { game: game, session_pdbprefix: pdbprefix, session_season: session, current_user_id: remaining_user.user_season.user.id },
        target: "game_#{game.hashid}")
    end
  end
end