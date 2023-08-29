class GameCardJob < ApplicationJob
  queue_as :games

  def perform(game, pdbprefix, user)
    Turbo::StreamsChannel.broadcast_replace_to(
      "games_#{game.home.user_season.user.id}",
      partial: "games/card",
      locals: { game: game, session_pdbprefix: pdbprefix, current_user_id: user.id },
      target: "game_#{game.hashid}")

    Turbo::StreamsChannel.broadcast_replace_to(
      "games_#{game.visitor.user_season.user.id}",
      partial: "games/card",
      locals: { game: game, session_pdbprefix: pdbprefix, current_user_id: user.id },
      target: "game_#{game.hashid}")
  end
end