class Manager::ChampionshipsController < ApplicationController
  authorize_resource class: false
  before_action :set_local_vars
  before_action :set_championship, only: [:details, :define_clubs]
  breadcrumb "dashboard", :root_path, match: :exact, turbo: "false"
  breadcrumb "manager.championships.main", :manager_championships_path, match: :exact, frame: "main_frame"

  def index
    if @season
      @championships = Championship.where(season_id: @season.id).order(updated_at: :desc)
      @seasons = Season.where(league_id: session[:league]).order(updated_at: :desc)
    end
  end

  def new
    @championship = Championship.new
    @cTypes = Championship.types
    @awards = Award.where(league_id: current_user.preferences["active_league"]).order("id ASC")
    @award_result_type = AppServices::Award.new().list_awards
  end

  def check_championship_name
    season = Championship.exists?(name: params[:championship][:name], season_id: @season.id) ? :unauthorized : :ok
    render body: nil, status: season
  end
  
  def set_championship
    @championship = Championship.find_by_hashid(params[:id])
  end

  def get_ctype_partial
    @ctype = params[:ctype]
    @sStarted = false
    case @ctype
    when "league"

    end
  end

  def create
    ## Time Course
    time_course = championship_params[:time_course].split(" ")
    time_start = time_course[0]
    time_end = time_course[2].nil? ? time_start : time_course[2]

    ## New Champ
    @championship = Championship.new
    @championship.name = championship_params[:name]

    ## Open Badge fila again
    if championship_params[:badge] == ""
      @championship.badge = championship_params[:original_badge]
    else
      championship_params[:badge].open
      @championship.badge = championship_params[:badge]
    end

    @championship.status = 0
    @championship.season_id = @season.id
    @championship.advertisement = championship_params[:advertisement]
    case championship_params[:ctype]
    when "league"
      @championship.preferences = {
        time_start: time_start,
        time_end: time_end,
        ctype: championship_params[:ctype],
        league_two_rounds: championship_params[:league_two_rounds],
        league_finals: championship_params[:league_finals],
        league_criterion: championship_params[:league_criterion],
        hattrick_earning: championship_params[:hattrick_earning],
        cards_suspension: championship_params[:cards_suspension],
        match_best_player: championship_params[:match_best_player],
        match_winning_earning: championship_params[:match_winning_earning],
        match_draw_earning: championship_params[:match_draw_earning],
        match_lost_earning: championship_params[:match_lost_earning],
        match_goal_earning: championship_params[:match_goal_earning],
        match_goal_lost: championship_params[:match_goal_lost],
        match_yellow_card_loss: championship_params[:match_yellow_card_loss],
        match_red_card_loss: championship_params[:match_red_card_loss],
        match_winning_ranking: championship_params[:match_winning_ranking],
        match_draw_ranking: championship_params[:match_draw_ranking],
        match_lost_ranking: championship_params[:match_lost_ranking],
        award_firstplace: championship_params[:firstplace],
        award_secondplace: championship_params[:secondplace],
        award_thirdplace: championship_params[:thirdplace],
        award_fourthtplace: championship_params[:fourthplace],
        award_goaler: championship_params[:goaler],
        award_assister: championship_params[:assister],
        award_fairplay: championship_params[:fairplay]
      }
    when "cup"
      @championship.preferences = {
        time_start: time_start,
        time_end: time_end,
        ctype: championship_params[:ctype],
        cup_number_of_groups: championship_params[:cup_number_of_groups],
        cup_teams_that_classify: championship_params[:cup_teams_that_classify],
        cup_group_two_rounds: championship_params[:cup_group_two_rounds],
        cup_switching: championship_params[:cup_switching],
        cup_criterion: championship_params[:cup_criterion],
        hattrick_earning: championship_params[:hattrick_earning],
        cards_suspension: championship_params[:cards_suspension],
        match_best_player: championship_params[:match_best_player],
        match_winning_earning: championship_params[:match_winning_earning],
        match_draw_earning: championship_params[:match_draw_earning],
        match_lost_earning: championship_params[:match_lost_earning],
        match_goal_earning: championship_params[:match_goal_earning],
        match_goal_lost: championship_params[:match_goal_lost],
        match_yellow_card_loss: championship_params[:match_yellow_card_loss],
        match_red_card_loss: championship_params[:match_red_card_loss],
        match_winning_ranking: championship_params[:match_winning_ranking],
        match_draw_ranking: championship_params[:match_draw_ranking],
        match_lost_ranking: championship_params[:match_lost_ranking],
        award: championship_params[:award]
      }
    when "brackets"
      @championship.preferences = {
        time_start: time_start,
        time_end: time_end,
        ctype: championship_params[:ctype],
        bracket_two_rounds: championship_params[:bracket_two_rounds],
        bracket_criterion: championship_params[:bracket_criterion],
        hattrick_earning: championship_params[:hattrick_earning],
        cards_suspension: championship_params[:cards_suspension],
        match_best_player: championship_params[:match_best_player],
        match_winning_earning: championship_params[:match_winning_earning],
        match_draw_earning: championship_params[:match_draw_earning],
        match_lost_earning: championship_params[:match_lost_earning],
        match_goal_earning: championship_params[:match_goal_earning],
        match_goal_lost: championship_params[:match_goal_lost],
        match_yellow_card_loss: championship_params[:match_yellow_card_loss],
        match_red_card_loss: championship_params[:match_red_card_loss],
        match_winning_ranking: championship_params[:match_winning_ranking],
        match_draw_ranking: championship_params[:match_draw_ranking],
        match_lost_ranking: championship_params[:match_lost_ranking],
        award: championship_params[:award]
      }
    end

    respond_to do |format|
      if @championship.save!
        # User.joins(:user_leagues).where('league_id = ? AND status = ?', @league.id, true).each do |user|
        #   uSeason = UserSeason.create(user_id: user.id, season_id: @season.id)
        # end

        # SeasonNotification.with(
        #   season: @season,
        #   league: @season.league_id,
        #   icon: "stack",
        #   push: true,
        #   push_type: "user",
        #   push_message: "#{t('.wnotify_subject', season: @season.name)}||#{t('.wnotify_text')}",
        #   type: "new").deliver_later(current_user)

        flash.now["success"] = t(".success")
        format.html { redirect_to manager_championships_path, notice: t(".success") }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def details
    breadcrumb @championship.name, :manager_championship_details_path
    if @championship.status == 100
      @cPositions = ChampionshipPosition.where(championship_id: @championship.id).order(position: :asc)
    end

    # @goalers = Championship.getGoalers(@championship).limit(5)
    # @assists = Championship.getAssisters(@championship).limit(5)
    # @fairplay = Championship.getFairPlay(@championship).limit(5)
    # @bestplayer = Championship.getBestPlayer(@championship).limit(5)
    # @lGames = Game.where(championship_id: @championship.id, status: 4).order(updated_at: :desc).limit(5)
    @user_season = UserSeason.where(season_id: @season.id).includes(:user)
  end

  # def define_clubs
  #   @championship = Championship.find_by_hashid(params[:id])
  #   cClubs = params[:championship_clubs]
  #   cClubs.each do |cClub|
  #     cChampionship = ClubChampionship.new(
  #       club_id: cClub,
  #       championship_id: @championship.id
  #     ).save!
  #   end
  #   respond_to do |format|
  #     flash.now["success"] = t(".success")
  #     format.html { redirect_to manager_championship_details_path(@championship.hashid), notice: t(".success") }
  #     format.turbo_stream
  #   end
  # end

  def define_clubs
    if request.patch?
      show_step(ManagerServices::Championship::Club.call(@championship, current_user, define_clubs_params), t(".clubs.success"))
    else
      @clubs = Season.getClubs(@season.id)
    end
  end

  def show_step(resolution, success_message)
    respond_to do |format|
      if resolution.success?
        # details
        flash.now["success"] = success_message
        format.turbo_stream { render "show_step" }
        format.html { redirect_to manager_championships_path, notice: success_message }
      else
        flash.now["error"] = I18n.t("defaults.errors.season.#{resolution.error}")
        format.html { render :details, status: :unprocessable_entity }
      end
    end
  end

  def cactions
    @championship = Championship.find_by_hashid(params[:id])
    case params[:caction]
    when "choose_clubs"
      @uLeague = UserSeason.includes(:user, [clubs: :def_team]).where(season_id: @season.id)
      render "choose_clubs"
    when "start_championship"
      case @championship.preferences["ctype"]
      when "league"
        listOfClubs = lClubs = ClubChampionship.where(championship_id: @championship.id).pluck(:club_id)
        firstHalf = []
        secondHalf = []
        i = 0

        listOfClubs = listOfClubs.permutation(2).to_a
        listOfClubs = listOfClubs.shuffle
        listOfClubsHalfs = listOfClubs.count / 2
        while i < listOfClubsHalfs
          firstHalf << [listOfClubs[0][0], listOfClubs[0][1]]
          secondHalf << [listOfClubs[0][1], listOfClubs[0][0]]
          listOfClubs.delete_at(listOfClubs.find_index([listOfClubs[0][1], listOfClubs[0][0]]))
          listOfClubs.delete_at(0)
          i += 1
        end

        # firstHalf.each do |game|
        #   Game.create(
        #     championship_id: @championship.id,
        #     home_id: game[0],
        #     visitor_id: game[1],
        #     phase: 1,
        #     status: 0
        #     )
        # end

        # if @championship.preferences["league_two_rounds"] == "on"
        #   secondHalf.each do |game|
        #     Game.create(
        #       championship_id: @championship.id,
        #       home_id: game[0],
        #       visitor_id: game[1],
        #       phase: 2,
        #       status: 0
        #       )
        #   end
        # end

        lClubs.each do |lClub|
          user = Club.getUser(lClub, @season.id)
          ChampionshipNotification.with(
            championship: @championship,
            league: @season.league_id,
            icon: "trophy",
            push: true,
            push_type: "user",
            push_message: "#{t(".wnotify_subject", championship: @championship.name)}||#{t(".wnotify_text")}",
            type: "start_championship"
          ).deliver_later(user)
        end

        # ChampionshipNotification.with(
        #   championship: @championship,
        #   league: @season.league_id,
        #   icon: "trophy",
        #   push: true,
        #   push_type: "user",
        #   push_message: "#{t('.wnotify_subject', championship: @championship.name)}||#{t('.wnotify_text')}",
        #   type: "start_championship").deliver_later(user)

      when "cup"
      when "brackets"
      end

      respond_to do |format|
        # if @championship.update(status: 1)
        flash.now["success"] = t(".success")
        # else
        #   flash.now["danger"] = t('.error')
        # end
        format.turbo_stream
        format.html { redirect_to manager_championship_details_path(@championship.hashid) }
      end

    when "start_league_round"
      ## Change Championship Status
      @championship.update(status: 2)

      ## WebPush Notify User about new Hire
      Push::Notify.group_notify(
        "championship",
        current_user.id,
        @championship,
        "start_league_round",
        "Turno do Camepenato #{@championship.name} Iniciado! Você já pode realizar seus jogos do turno.",
        true,
        @season.id
      )

      flash[:success] = "Turno do Campeonato #{@championship.name} Iniciado com sucesso!"
    when "start_league_secondround"
      ## Check for any missing game and declare Draw
      # All Championship Games
      allG = Game.where(championship_id: @championship.id, phase: "firstRound").where("status < ?", 4).order(created_at: :asc)
      if allG.size == 0
        ## All Games Finished so we're good to move to next phase

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
      else
        nfGames = Game.where(championship_id: @championship.id, phase: "firstRound").where("status > ? AND status < ?", 0, 4).order(created_at: :asc)
        if nfGames.size > 0
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

    ## League Semifinals
    when "start_league_semifinals"

      # Check Championship Rounds
      nfGames = if @championship.preferences["league_two_rounds"] == "on"
        Game.where(championship_id: @championship.id, phase: "secondRound").where("status > ? AND status < ?", 1, 4).order(created_at: :asc)
      else
        Game.where(championship_id: @championship.id, phase: "firstRound").where("status > ? AND status < ?", 1, 4).order(created_at: :asc)
      end

      if nfGames.size > 0
        flash[:error] = "Existem jogos em Andamento! Cancele/Comunique os jogadores para finalizar os jogos antes de encerrar o turno!"
      else
        cGames = if @championship.preferences["league_two_rounds"] == "on"
          Game.where(championship_id: @championship.id, phase: "secondRound", status: 0).order(created_at: :asc)
        else
          Game.where(championship_id: @championship.id, phase: "firstRound", status: 0).order(created_at: :asc)
        end

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

        #####
        ## Now its time to create the Semifinal games
        #####

        ## Get Semifinal Standing
        standing = Standing.getStanding(@championship.id)

        ## Create 1st/2nd Semi
        @home = Club.find(standing[0][0])
        @visitor = Club.find(standing[3][0])

        firstSemi = Game.create(
          championship_id: @championship.id,
          home_id: @visitor.id,
          visitor_id: @home.id,
          phase: "semifinals",
          status: 0,
          wo: false
        )
        secondSemi = Game.create(
          championship_id: @championship.id,
          home_id: @home.id,
          visitor_id: @visitor.id,
          phase: "semifinals",
          status: 0,
          wo: false
        )

        ## Create 3rd/4th Semi
        @home = Club.find(standing[1][0])
        @visitor = Club.find(standing[2][0])

        thirdSemi = Game.create(
          championship_id: @championship.id,
          home_id: @visitor.id,
          visitor_id: @home.id,
          phase: "semifinals",
          status: 0,
          wo: false
        )
        fourthSemi = Game.create(
          championship_id: @championship.id,
          home_id: @home.id,
          visitor_id: @visitor.id,
          phase: "semifinals",
          status: 0,
          wo: false
        )

        ## WebPush Notify User about new Hire
        Push::Notify.group_notify(
          "championship",
          current_user.id,
          @championship,
          "start_league_semifinals",
          "Semifinais do Campeonato #{@championship.name} Iniciadas! Você já pode realizar seus jogos.",
          true,
          @season.id
        )

        ## Change Championship Status
        @championship.update(status: 5)

        flash[:success] = "Jogos das Semifinais liberados para os usuários!"
      end

    ## League Finals
    when "start_league_finals"
      nfGames = Game.where(championship_id: params[:id], phase: "semifinals").where("status < ?", 4).order(created_at: :asc)
      if nfGames.size > 0
        flash[:error] = "Existem jogos Não Iniciados/Em Andamento! Cancele/Comunique os jogadores para finalizar os jogos antes de encerrar as Semifinais!"
      else
        ## Check Winners first
        thome = ""
        tvisitor = ""
        finals = []
        prevSemi = Game.where(championship_id: @championship.id, phase: "semifinals", status: 4).order(created_at: :asc)
        prevSemi.each do |game|
          if game.home_id == thome || game.visitor_id == thome
            ## Opponent Game
            opGame = Game.where(championship_id: @championship.id, phase: "semifinals", status: 4, home_id: game.visitor_id, visitor_id: game.home_id).first

            finals.push(Game.getWinnerLost(opGame, game))
          end
          thome = game.home_id
          tvisitor = game.visitor_id
        end

        standing = Standing.getStanding(@championship.id)

        thirdFourthHome = (standing.index { |el| el[0] == finals[0][:lost] } + 1 < standing.index { |el| el[0] == finals[1][:lost] } + 1) ? finals[0][:lost] : finals[1][:lost]
        thirdFourthVisitor = (thirdFourthHome == finals[0][:lost]) ? finals[1][:lost] : finals[0][:lost]

        ## Create 3rd4th
        first3rd4th = Game.create(
          championship_id: @championship.id,
          home_id: Club.find(thirdFourthVisitor).id,
          visitor_id: Club.find(thirdFourthHome).id,
          phase: "3rd4th",
          status: 0,
          wo: false
        )
        second3rd4th = Game.create(
          championship_id: @championship.id,
          home_id: Club.find(thirdFourthHome).id,
          visitor_id: Club.find(thirdFourthVisitor).id,
          phase: "3rd4th",
          status: 0,
          wo: false
        )

        finalHome = (standing.index { |el| el[0] == finals[0][:win] } + 1 < standing.index { |el| el[0] == finals[1][:win] } + 1) ? finals[0][:win] : finals[1][:win]
        finalVisitor = (finalHome == finals[0][:win]) ? finals[1][:win] : finals[0][:win]

        ## Create Final Game
        firstFinal = Game.create(
          championship_id: @championship.id,
          home_id: Club.find(finalVisitor).id,
          visitor_id: Club.find(finalHome).id,
          phase: "finals",
          status: 0,
          wo: false
        )
        secondFinal = Game.create(
          championship_id: @championship.id,
          home_id: Club.find(finalHome).id,
          visitor_id: Club.find(finalVisitor).id,
          phase: "finals",
          status: 0,
          wo: false
        )

        ## WebPush Notify User about new Hire
        Push::Notify.group_notify(
          "championship",
          current_user.id,
          @championship,
          "start_league_finals",
          "Finais do Campeonato #{@championship.name} Iniciadas! Você já pode realizar seus jogos.",
          true,
          @season.id
        )

        ## Change Championship Status
        @championship.update(status: 6)

        flash[:success] = "Finais Liberadas para os Usuários!"

      end

    ## Finish Champ
    when "finish_championship"
      nfGames = Game.where(championship_id: params[:id]).where("status < ?", 4).order(created_at: :asc)
      if nfGames.size > 0
        flash[:error] = "Existem jogos em Andamento! Cancele/Comunique os jogadores para finalizar os jogos antes de encerrar o Campeonato!"
      else

        ###
        ## Initial Checks

        # Type of Championship
        case @championship.preferences["ctype"]
        when "league"
          # Finals On?
          if @championship.preferences["league_finals"] == "on"
            # Ok, so finals were made,
            # now we can get the winners/losers and update

            # Final Positions
            firstSecondGame = Game.where(championship_id: @championship.id, phase: "finals", status: 4).order(created_at: :asc)
            firstSecondPos = Game.getWinnerLost(firstSecondGame.first, firstSecondGame.second)

            thirdFourthGame = Game.where(championship_id: @championship.id, phase: "3rd4th", status: 4).order(created_at: :asc)
            thirdFourthPos = Game.getWinnerLost(thirdFourthGame.first, thirdFourthGame.second)

            first = firstSecondPos[:win]
            second = firstSecondPos[:lost]
            third = thirdFourthPos[:win]
            fourth = thirdFourthPos[:lost]

          else
            # Theres no Finals, so we just get the
            # first 4 clubs general Classification

            # Get Semifinal Standing
            standing = Standing.getStanding(@championship.id)

            first = Club.find(standing[0][0])
            second = Club.find(standing[1][0])
            third = Club.find(standing[2][0])
            fourth = Club.find(standing[3][0])

          end

          ## Create Entries for Champ Positions
          # Maybe its not the best but its easier to get
          # final positions in the future and doesnt
          # require any additional calcs

          ChampionshipPosition.where(
            championship_id: @championship.id,
            club_id: first,
            position: 1
          ).first_or_create!

          ChampionshipPosition.where(
            championship_id: @championship.id,
            club_id: second,
            position: 2
          ).first_or_create!

          ChampionshipPosition.where(
            championship_id: @championship.id,
            club_id: third,
            position: 3
          ).first_or_create!

          ChampionshipPosition.where(
            championship_id: @championship.id,
            club_id: fourth,
            position: 4
          ).first_or_create!

        end

        ## Check for Awards and Give
        # Prizes to each club
        Award.updatePrizes(@championship, "confirm")

        ## Change Championship Status
        @championship.update(status: 100)

        flash[:success] = "Campeonato Encerrado com Sucesso!"
      end
    end

    # redirect_to manager_championship_details_path(@championship.hashid)
  end

  def destroy
    @championship = Championship.find_by_hashid(params[:id])
    return flash[:warning] = t('.championship_in_progress') if @championship.status == 1

    games = Game.where(championship_id: @championship.id, status: 4)
    games.each do |game|
      ClubFinance.updateEarnings(game, "cancel")
      Ranking.updateRanking(game, "cancel")
    end

    Award.updatePrizes(@championship, "cancel") if @championship.status == 20

    if @championship.destroy
      flash[:success] = t(".championship_removed")
    else
      flash[:error] = t(".error_removing_championship")
    end

    redirect_to manager_championships_path
  end

  private

  def set_local_vars
    if session[:season]
      @season = Season.find(session[:season])
    end
  end

  def define_clubs_params
    params.permit(championship_clubs: [])
  end

  def championship_params
    params.require(:championship).permit(
      :badge,
      :name,
      :time_course,
      :ctype,
      :league_two_rounds,
      :league_finals,
      :league_criterion,
      :cup_number_of_groups,
      :cup_teams_that_classify,
      :cup_switching,
      :cup_criterion,
      :bracket_two_rounds,
      :bracket_criterion,
      :hattrick_earning,
      :cards_suspension,
      :match_best_player,
      :match_winning_earning,
      :match_draw_earning,
      :match_lost_loss,
      :match_goal_earning,
      :match_goal_lost,
      :match_yellow_card_loss,
      :match_red_card_loss,
      :match_winning_ranking,
      :match_draw_ranking,
      :match_lost_ranking,
      :advertisement,
      :firstplace,
      :secondplace,
      :thirdplace,
      :fourthplace,
      :goaler,
      :assister,
      :fairplay
    )
  end
end
