class GameCardJob < ApplicationJob
  queue_as :games

  def perform(game, pdbprefix, user)
    home = game.home.user_season.user
    visitor = game.visitor.user_season.user
    remaining_users = User.joins(:seasons).where("seasons.id = ? AND ( users.id = ? OR users.id = ?)", game.championship.season.id, home.id, visitor.id)

    Turbo::StreamsChannel.broadcast_replace_to(
      "games_#{home.id}",
      partial: "games/card",
      locals: { game: game, session_pdbprefix: pdbprefix, current_user_id: user.id },
      target: "game_#{game.hashid}")

    Turbo::StreamsChannel.broadcast_replace_to(
      "games_#{visitor.id}",
      partial: "games/card",
      locals: { game: game, session_pdbprefix: pdbprefix, current_user_id: user.id },
      target: "game_#{game.hashid}")

    remaining_users.each do |remaining_user|
      Turbo::StreamsChannel.broadcast_replace_to(
        "games_#{remaining_user.id}",
        partial: "games/card",
        locals: { game: game, session_pdbprefix: pdbprefix, current_user_id: user.id },
        target: "game_#{game.hashid}")
    end
  end
end