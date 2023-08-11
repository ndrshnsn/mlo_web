class AppServices::Games::Wo < ApplicationService
  def initialize(game)
    @game = game
  end

  def call
    ActiveRecord::Base.transaction do
      apply_wo
    end
  end

  private

  def apply_wo
    if @game.status > 0 && @game.status < 3
      GameCard.where(game_id: @game.id).destroy_all
      ClubGame.where(game_id: @game.id).destroy_all
      Sidekiq::Cron::Job.find("result_confirmation_#{@game.championship.season.id}_#{@game.championship.id}_#{@game.id}").destroy
    end

    @game.status = 4
    @game.wo = true
    @game.hscore = 0
    @game.vscore = 0
    @game.hsaccepted = true
    @game.vsaccepted = true
    @game.hfaccepted = true
    @game.vfaccepted = true
    @game.eresults_id = nil
    @game.save!

    ClubFinance.updateEarnings(@game, "confirm")
    Ranking.updateRanking(@game, "confirm")

    OpenStruct.new(success?: true, game: @game, error: nil)
  end

  def handle_error(game, error)
    OpenStruct.new(success?: false, game: @game, error: error)
  end

  def broadcast
    ## Render   
    gameCard = render_to_string partial: 'championships/games/card', locals: { game: @game, iteration: @iteration, current_user_id: @game.home.user_season.user.id }


    # Update Visitor/Home and Others Game Card
    ActionCable.server.broadcast "gameCard:#{@season.id}_#{@game.home.user_season.user.id}", {
        sender: current_user.id,
        audience: "match",
        championship_id: @game.championship.hashid,
        game_id: @game.hashid,
        gameCard: gameCard,
        home_id: @game.home.user_season.user.id,
        visitor_id: @game.visitor.user_season.user.id,
        phase: "reload_card"
    }

    ## Render   
    gameCard = render_to_string partial: 'championships/games/card', locals: { game: @game, iteration: @iteration, current_user_id: @game.visitor.user_season.user.id }

    ActionCable.server.broadcast "gameCard:#{@season.id}_#{@game.visitor.user_season.user.id}", {
        sender: current_user.id,
        audience: "match",
        championship_id: @game.championship.hashid,
        game_id: @game.hashid,
        gameCard: gameCard,
        home_id: @game.home.user_season.user.id,
        visitor_id: @game.visitor.user_season.user.id,
        phase: "reload_card"
    }

    ## Render   
    gameCard = render_to_string partial: 'championships/games/card', locals: { game: @game, iteration: @iteration }

    ActionCable.server.broadcast "gameCard:#{@season.id}", {
        sender: current_user.id,
        audience: "others",
        championship_id: @game.championship.hashid,
        game_id: @game.hashid,
        gameCard: gameCard,
        home_id: @game.home.user_season.user.id,
        visitor_id: @game.visitor.user_season.user.id,
        phase: "reload_card"
    }
  end
end
