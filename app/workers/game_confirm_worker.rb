class GameConfirmWorker
  include Sidekiq::Worker
  queue_as :games
  sidekiq_options retry: 2

  def perform(game_id, season_id, current_user_id, session_pdbprefix, date)
    season = Season.find(season_id)
    current_user = User.find(current_user_id)
    user_club = User.getClub(current_user_id, season_id)
    game = Game.find(game_id)

    resolution = AppServices::Games::Confirm.call(game, current_user, user_club)
    GameCardJob.perform_later(game, session_pdbprefix, season, current_user) if resolution.success?
  end
end