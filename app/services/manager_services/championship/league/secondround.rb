class ManagerServices::Championship::League::SecondRound < ApplicationService
  def initialize(championship, user, params)
    @championship = championship
    @user = user
    @params = params
  end

  def call
    ActiveRecord::Base.transaction do
      start_league_second_round
    end
  end

  private

  def start_league_second_round

    case @params[:selected]
    when "first_method"
      first_method
    when "second_method"
      second_method
    end

    return handle_error(@championship, @championship&.error) unless @championship.update!(status: 3)

    ### NOTIFY

    OpenStruct.new(success?: true, championship: @championship, error: nil)
  end

  def first_method
    all_games = Game.where(championship_id: @championship.id, phase: "firstRound")
    if all_games.where("status < ?", 4).size > 0
      not_finished_games = all_games.where("status > ? AND status < ?", 0, 4).order(created_at: :asc)

      if not_finished_games.size > 0
        flash[:error] = "Existem jogos em Andamento! Cancele/Comunique os jogadores para finalizar os jogos antes de encerrar o turno!"
      else
        cGames = Game.where(championship_id: @championship.id, phase: "firstRound", status: 0).order(created_at: :asc)
        cGames.each_with_index do |cGame, i|
          iteration = i + 1

          cGame.hscore = 0
          cGame.vscore = 0
          cGame.status = 4
          cGame.wo = true
          cGame.home_start_accepted = true
          cGame.visitor_start_accepted = true
          cGame.home_finish_accepted = true
          cGame.visitor_finish_accepted = true
          cGame.entering_results_id = nil
          cGame.save!

          ## Update Club Earnings
          ClubFinance.updateEarnings(cGame, "confirm")

          ## Update Global Ranking
          Ranking.updateRanking(cGame, "confirm")

          ## Status
          @gameStatus = Game.getStatus(cGame.id)

          ## Render
          gameCard = render_to_string partial: "championships/games/card", locals: {game: cGame, iteration: iteration, current_user_id: cGame.home.user_season.user.id}

          # Update Visitor/Home and Others Game Card
          ActionCable.server.broadcast "gameCard:#{@season.id}_#{cGame.home.user_season.user.id}", {
            sender: current_user.id,
            audience: "match",
            championship_id: cGame.championship.hashid,
            game_id: cGame.hashid,
            gameCard: gameCard,
            home_id: cGame.home.user_season.user.id,
            visitor_id: cGame.visitor.user_season.user.id,
            phase: "reload_card"
          }

          ## Render
          gameCard = render_to_string partial: "championships/games/card", locals: {game: cGame, iteration: iteration, current_user_id: cGame.visitor.user_season.user.id}

          ActionCable.server.broadcast "gameCard:#{@season.id}_#{cGame.visitor.user_season.user.id}", {
            sender: current_user.id,
            audience: "match",
            championship_id: cGame.championship.hashid,
            game_id: cGame.hashid,
            gameCard: gameCard,
            home_id: cGame.home.user_season.user.id,
            visitor_id: cGame.visitor.user_season.user.id,
            phase: "reload_card"
          }

          ## Render
          gameCard = render_to_string partial: "championships/games/card", locals: {game: cGame, iteration: iteration}

          ActionCable.server.broadcast "gameCard:#{@season.id}", {
            sender: current_user.id,
            audience: "others",
            championship_id: cGame.championship.hashid,
            game_id: cGame.hashid,
            gameCard: gameCard,
            home_id: cGame.home.user_season.user.id,
            visitor_id: cGame.visitor.user_season.user.id,
            phase: "reload_card"
          }
        end

        ## Change Championship Status
        @championship.update(status: 3)

        ## WebPush Notify User about new Hire
        Push::Notify.group_notify(
          "championship",
          current_user.id,
          @championship,
          "start_league_secondround",
          "Returno do Campeonato #{@championship.name} Iniciado! Você já pode realizar seus jogos do returno.",
          true,
          @season.id
        )

        flash[:success] = "Returno do Campeonato #{@championship.name} Iniciado com sucesso!"
      end
    end
  end

  def second_method
    when "start_league_secondround_option2"
      ## Change Championship Status
      @championship.preferences["secondRound_allowed_with_no_wo"] = true
      @championship.status = 4
      @championship.save!

      ## WebPush Notify User about new Hire
      Push::Notify.group_notify(
        "championship",
        current_user.id,
        @championship,
        "start_league_secondround",
        "Returno do Campeonato #{@championship.name} Iniciado! Você já pode realizar seus jogos do returno.",
        true,
        @season.id
      )

      flash[:success] = "Returno do Campeonato #{@championship.name} Iniciado com sucesso!"
  end

  def notify

    # Push::Notify.group_notify(
    #   "championship",
    #   current_user.id,
    #   @championship,
    #   "start_league_round",
    #   "Turno do Camepenato #{@championship.name} Iniciado! Você já pode realizar seus jogos do turno.",
    #   true,
    #   @season.id
    # )

    SeasonNotification.with(
      season: season,
      league: season.league_id,
      icon: "stack",
      type: "start",
      push: true,
      push_message: "#{I18n.t("manager.seasons.steps.start.wnotify_subject", season: season.name)}||#{I18n.t("manager.seasons.steps.start.wnotify_text")}"
    ).deliver_later(@user)

    SeasonNotification.with(
      season: season,
      league: season.league_id,
      icon: "stack",
      type: "start",
      push: true,
      push_message: "#{I18n.t("manager.seasons.steps.start.wnotify_subject", season: season.name)}||#{I18n.t("manager.seasons.steps.start.wnotify_text")}"
    ).deliver_later(User.joins(:user_seasons).where("user_seasons.season_id = ? AND users.preferences -> 'fake' IS NULL", season.id))
  end

  def handle_error(season, error)
    OpenStruct.new(success?: false, championship: @championship, error: error)
  end
end
