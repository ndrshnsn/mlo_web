class GameConfirmWorker
  include Sidekiq::Worker
  sidekiq_options retry: 2

  include ApplicationHelper

  def perform(season_id, current_user_id, date)
    @season = Season.find(season_id)
    @user = User.find(current_user_id)
    
    Sidekiq::Cron::Job.find("result_confirmation_#{@season.id}_#{game.championship.id}_#{game.id}").destroy

  end
end