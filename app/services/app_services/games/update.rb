class AppServices::Games::Update < ApplicationService
  def initialize(game, user, params)
    @game = game
    @user = user
    @params = params
  end

  def call
    ActiveRecord::Base.transaction do
      update_game
    end
  end

  private

  def update_game
    return handle_error(@game, ".game_already_finished") unless @game.status < 3

    unless @game.mresult
      user_club = @params[:club]
      side = @game.home == user_club ? "home" : "visitor"
      opponent = @game.home.user_season.user.id == @user.id ? "visitor" : "home"
    end
    goals_home = goals_visitor = 0

    if @params[:data][:goals_home]
      goals_home = @params[:data][:goals_home].count
      @params[:data][:goals_home].each do |goal|
        goaler = PlayerSeason.find(eval(goal)[0])
        assister = eval(goal)[1] == "-" ? nil : PlayerSeason.find(eval(goal)[1]).id

        club_game = ClubGame.new(
          game_id: @game.id,
          club_id: @game.home.id,
          player_season_id: goaler.id,
          assist_id: assister
        )
        return handle_error(@game, @game&error) unless club_game.save!
      end
    end

    if @params[:data][:goals_visitor]
      goals_visitor = @params[:data][:goals_visitor].count
      @params[:data][:goals_visitor].each do |goal|
        goaler = PlayerSeason.find(eval(goal)[0])
        assister = eval(goal)[1] == "-" ? nil : PlayerSeason.find(eval(goal)[1]).id

        club_game = ClubGame.new(
          game_id: @game.id,
          club_id: @game.visitor.id,
          player_season_id: goaler.id,
          assist_id: assister
        )
        return handle_error(@game, @game&error) unless club_game.save!
      end
    end

    @game.hscore = goals_home
    @game.vscore = goals_visitor

    return handle_error(@game, @game&error) unless AppServices::Games::UpdateCard.call(@game, "confirm")

    if @params[:data][:cards_home]
      @params[:data][:cards_home].each do |card|
        card = eval(card)
        player_season = PlayerSeason.find(card[0])

        game_card = GameCard.new(
          game_id: @game.id,
          club_id: @game.home.id,
          player_season_id: player_season.id
          )

        if card[1] == "game_ycard"
          game_card.ycard = true
          player_season.details["ycard"] = player_season.details["ycard"].to_i + 1
        end
        
        if card[1] == "game_rcard"
          game_card.rcard = true
          player_season.details["rcard"] = 1
        end

        return handle_error(@game, @game&error) unless player_season.save!
        return handle_error(@game, @game&error) unless game_card.save!
      end
    end

    if @params[:data][:cards_visitor]
      @params[:data][:cards_visitor].each do |card|
        card = eval(card)
        player_season = PlayerSeason.find(card[0])

        game_card = GameCard.new(
          game_id: @game.id,
          club_id: @game.visitor.id,
          player_season_id: player_season.id
          )

        if card[1] == "game_ycard"
          game_card.ycard = true
          player_season.details["ycard"] = player_season.details["ycard"].to_i + 1
        end
        
        if card[1] == "game_rcard"
          game_card.rcard = true
          player_season.details["rcard"] = 1
        end

        return handle_error(@game, @game&error) unless player_season.save!
        return handle_error(@game, @game&error) unless game_card.save!
      end
    end

    
    @game.phscore = @params[:data]["phscore"] if @params[:data]["phscore"]
    @game.pvscore = @params[:data]["pvscore"] if @params[:data]["pvscore"]
    
    if @game.championship.preferences["match_best_player"] == "on"
      best_player = PlayerSeason.find(@params[:data][:match_best_player_selection])

      club_best_player = GameBestPlayer.new(
        game_id: @game.id,
        player_season_id: best_player.id,
        club_id: best_player.club_players.first.club.id
      )
      return handle_error(@game, @game&error) unless club_best_player.save!
    end

    if @game.mresult
      @game.status = 3
    else
      @game.status = 2
      if side == "home"
        @game.hfaccepted = true
      else
        @game.vfaccepted = true
      end
    end

    return handle_error(@game, @game&error) unless @game.save!

    if @game.mresult

      return handle_error(@game, ".game_confirm_earning_error") unless AppServices::Games::Earning.new(@game).pay()
      return handle_error(@game, ".game_confirm_standing_error") unless AppServices::Championship::Standing.new(@game).update()
      return handle_error(@game, ".game_confirm_ranking_error") unless AppServices::Ranking.new(game: @game).update()

    else
      season = @game.championship.season
      confirmation_time = Time.zone.now + season.preferences["time_game_confirmation"].hour
      Sidekiq::Cron::Job.create(name: "game_confirm_#{season.id}_#{@game.championship.id}_#{@game.id}", cron: "#{Time.zone.now.strftime("%M")} #{confirmation_time.strftime("%H")} * * *", class: 'GameConfirmWorker', date_as_argument: true, args: [@game.id, season.id, @user.id, Rails.configuration.playerdb_prefix, Time.zone.now])
      sleep 1
    end

    OpenStruct.new(success?: true, game: @game, error: nil)
  end

  def handle_error(game, error)
    OpenStruct.new(success?: false, game: @game, error: error)
  end
end
