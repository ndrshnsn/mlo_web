class AppServices::Games::Confirm < ApplicationService
  def initialize(game, user)
    @game = game
    @user = user
  end

  def call
    ActiveRecord::Base.transaction do
      confirm_game
    end
  end

  private

  def confirm_game
    side = @game.home == session[:userClub] ? "home" : "visitor"
    opponent = @game.home.user_season.user.id == @user.id ? "visitor" : "home"

    @game.status = 3
    if side == "home"
      @game.hfaccepted = true
    else
      @game.vfaccepted = true
    end

    return handle_error(@game, ".game_start_error") unless @game.save!

    ## Remove Cron Job
    if Sidekiq::Cron::Job.find("result_confirmation_#{@season.id}_#{@game.championship.id}_#{@game.id}")
        Sidekiq::Cron::Job.find("result_confirmation_#{@season.id}_#{@game.championship.id}_#{@game.id}").destroy
    end

    ## Update Club Earnings
    ClubFinance.updateEarnings(@game, "confirm")

    ## Update Global Ranking
    Ranking.updateRanking(@game, "confirm")

    ## Render   
    gameCard = render_to_string partial: 'championships/games/card', locals: { game: @game, iteration: @iteration, current_user_id: @game.home.user_season.user.id }

    # Update Visitor/Home and Others Game Card
    ActionCable.server.broadcast "gameCard:#{@season.id}_#{@game.championship.id}_#{@game.home.user_season.user.id}", {
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

    ActionCable.server.broadcast "gameCard:#{@season.id}_#{@game.championship.id}_#{@game.visitor.user_season.user.id}", {
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

    ActionCable.server.broadcast "gameCard:#{@season.id}_#{@game.championship.id}", {
        sender: current_user.id,
        audience: "others",
        championship_id: @game.championship.hashid,
        game_id: @game.hashid,
        gameCard: gameCard,
        home_id: @game.home.user_season.user.id,
        visitor_id: @game.visitor.user_season.user.id,
        phase: "reload_card"
    }

    respond_to do |format|
        format.js { 
            flash.now[:success] = 'Jogo Confirmado, confira a Classificação atualizada e seus rendimentos após o jogo.'
            
        }
    end

    
    OpenStruct.new(success?: true, game: @game, error: nil)
  end

  def handle_error(game, error)
    OpenStruct.new(success?: false, game: @game, error: error)
  end
end
