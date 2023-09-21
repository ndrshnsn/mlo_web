class AppServices::Games::Confirm < ApplicationService
  def initialize(game, user, club)
    @game = game
    @user = user
    @club = club
  end

  def call
    ActiveRecord::Base.transaction do
      confirm_game
    end
  end

  private

  def confirm_game
    side = @game.home == @club ? "home" : "visitor"
    opponent = @game.home.user_season.user.id == @user.id ? "visitor" : "home"
    @game.status = 3
    if side == "home"
      @game.vfaccepted = true
    else
      @game.hfaccepted = true
    end
    return handle_error(@game, ".game_confirm_error") unless @game.save!

    Sidekiq::Cron::Job.destroy "game_confirm_#{@game.championship.season.id}_#{@game.championship.id}_#{@game.id}"
    
    return handle_error(@game, ".game_confirm_earning_error") unless AppServices::Games::Earning.new(@game).pay()
    return handle_error(@game, ".game_confirm_ranking_error") unless AppServices::Ranking.new(game: @game).update()

    OpenStruct.new(success?: true, game: @game, error: nil)
  end

  def handle_error(game, error)
    OpenStruct.new(success?: false, game: @game, error: error)
  end
end
