class Manager::ChampionshipsController < ApplicationController
  authorize_resource class: false
  before_action :set_local_vars
  before_action :set_championship, only: [:details, :define_clubs, :start, :start_league_round, :start_league_secondround, :games, :destroy, :update, :start_league_semi, :start_league_finals, :end]
  breadcrumb "dashboard", :root_path, match: :exact, turbo: "false"
  breadcrumb "manager.championships.main", :manager_championships_path, match: :exact, frame: "main_frame"

  def index
    if @season
      all_championships
      @seasons = Season.where(league_id: session[:league]).order(updated_at: :desc)
    end
  end

  def new
    @championship = Championship.new
    @cTypes = Championship.types
    @awards = Award.where(league_id: @league.id)
    @award_result_type = AppServices::Award.new().list_awards
  end

  def check_championship_name
    championship = Championship.exists?(name: params[:championship][:name], season_id: @season.id) ? :unauthorized : :ok
    if params[:id] != "none"
      championship = :ok if Championship.find(params[:id]).name == params[:championship][:name]
    end
      
    render body: nil, status: championship
  end

  def all_championships
    @championships = Championship.where(season_id: @season.id).order(updated_at: :desc)
  end
  
  def set_championship
    @championship = Championship.friendly.find(params[:id])
  end

  def get_ctype_partial
    if params[:id] != "none"
      @championship = Championship.find(params[:id])
      @sStarted = @championship.status > 0 ? true : false
    end
    @ctype = params[:ctype]
  end

  def games
    breadcrumb @championship.name, manager_championship_details_path(id: @championship.id), match: :exact, frame: "main_frame"
    @pagy, @games = pagy(Game.includes([home: :def_team], [visitor: :def_team]).where(championship_id: @championship.id).order(id: :asc))
  end

  def create
    time_course = championship_params[:time_course].split(" ")
    time_start = time_course[0]
    time_end = time_course[2].nil? ? time_start : time_course[2]

    @championship = Championship.new
    @championship.name = championship_params[:name]

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
        hattrick_earning: championship_params[:hattrick_earning].to_i,
        cards_suspension: championship_params[:cards_suspension],
        match_best_player: championship_params[:match_best_player],
        match_winning_earning: championship_params[:match_winning_earning].to_i,
        match_draw_earning: championship_params[:match_draw_earning].to_i,
        match_lost_earning: championship_params[:match_lost_earning].to_i,
        match_goal_earning: championship_params[:match_goal_earning].to_i,
        match_goal_lost: championship_params[:match_goal_lost].to_i,
        match_yellow_card_loss: championship_params[:match_yellow_card_loss].to_i,
        match_red_card_loss: championship_params[:match_red_card_loss].to_i,
        match_winning_ranking: championship_params[:match_winning_ranking].to_i,
        match_draw_ranking: championship_params[:match_draw_ranking].to_i,
        match_lost_ranking: championship_params[:match_lost_ranking].to_i
      }
    end

    respond_to do |format|
      if @championship.save!
        award_params[:award].each do |award|
          ChampionshipAward.create(
            championship_id: @championship.id,
            award_id: award[1].to_i,
            award_type: award[0]
            ) if award[1].to_i != 0
        end
        format.turbo_stream {flash.now["success"] = t(".success")}
        format.html { redirect_to manager_championships_path, notice: t(".success") }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def update
    time_course = championship_params[:time_course].split(" ")
    time_start = time_course[0]
    time_end = time_course[2].nil? ? time_start : time_course[2]

    @championship.name = championship_params[:name]
    @championship.badge = championship_params[:badge]
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
        hattrick_earning: championship_params[:hattrick_earning].to_i,
        cards_suspension: championship_params[:cards_suspension],
        match_best_player: championship_params[:match_best_player],
        match_winning_earning: championship_params[:match_winning_earning].to_i,
        match_draw_earning: championship_params[:match_draw_earning].to_i,
        match_lost_earning: championship_params[:match_lost_earning].to_i,
        match_goal_earning: championship_params[:match_goal_earning].to_i,
        match_goal_lost: championship_params[:match_goal_lost].to_i,
        match_yellow_card_loss: championship_params[:match_yellow_card_loss].to_i,
        match_red_card_loss: championship_params[:match_red_card_loss].to_i,
        match_winning_ranking: championship_params[:match_winning_ranking].to_i,
        match_draw_ranking: championship_params[:match_draw_ranking].to_i,
        match_lost_ranking: championship_params[:match_lost_ranking].to_i
      }
    end

    respond_to do |format|
      if @championship.save!
        award_params[:award].each do |award|
          if award[1] == "none"
            championship_award = ChampionshipAward.find_by(championship_id: @championship.id, award_type: award[0])
            championship_award.destroy! if !championship_award.nil?
          else
            ChampionshipAward.where(championship_id: @championship.id, award_type: award[0]).first_or_create do |championship_award|
              championship_award.award_id = award[1].to_i
            end
          end
        end
        format.turbo_stream {flash.now["success"] = t(".success")}
        format.html { redirect_to manager_championships_path, notice: t(".success") }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def settings
    @championship = Championship.friendly.find(params[:id])
    breadcrumb @championship.name, manager_championship_details_path(id: @championship.id), match: :exact, frame: "main_frame"
    @cTypes = Championship.types
    @awards = League.get_awards(@league.id)
    @award_result_type = AppServices::Award.new().list_awards
  end

  def details
    breadcrumb @championship.name, :manager_championship_details_path
    if @championship.status == 100
      @cPositions = ChampionshipPosition.where(championship_id: @championship.id).order(position: :asc)
    end

    @goalers = Championship.getGoalers(@championship)
    @assists = Championship.getAssisters(@championship)
    @fairplay = Championship.getFairPlay(@championship)
    @bestplayer = Championship.getBestPlayer(@championship)
    @lGames = Game.where(championship_id: @championship.id, status: 4).order(updated_at: :desc).limit(5)
    @user_season = UserSeason.where(season_id: @season.id).includes(:user)
  end

  def define_clubs
    if request.patch?
      show_step(ManagerServices::Championship::Club.call(@championship, current_user, define_clubs_params), t(".clubs.success"))
    else
      @clubs = Season.getClubs(@season.id)
    end
  end

  def start
    show_step(ManagerServices::Championship::Start.call(@championship, current_user), t(".success"))
  end

  def start_league_round
    show_step(ManagerServices::Championship::League::Round.call(@championship, current_user), t(".success"))
  end

  def start_league_secondround
    if request.post?
      show_step(ManagerServices::Championship::League::Secondround.call(@championship, current_user, params), t(".success"))
    end
  end

  def start_league_semi
    show_step(ManagerServices::Championship::League::Semi.call(@championship), t(".success"))
  end

  def start_league_finals
    show_step(ManagerServices::Championship::League::Final.call(@championship), t(".success"))
  end

  def end
    show_step(ManagerServices::Championship::End.call(@championship), t(".success"))
  end

  def destroy
    respond_to do |format|
      if @championship.status == 1
        format.turbo_stream { flash["error"] = t(".in_progress") }
        format.html { render :details, status: :unprocessable_entity, notice: t(".in_progress") }
      else
        games = Game.where(championship_id: @championship.id, status: 4)
        games.each do |game|
          AppServices::Games::Revoke.call(game)
        end
        
        if @championship.destroy!
          all_championships
          format.turbo_stream { flash["success"] = t(".success") }
          format.html { redirect_to manager_championships_path, notice: t(".success") }
        else
          format.html { render :details, status: :unprocessable_entity }
        end
      end
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
        flash.now["error"] = I18n.t("defaults.errors.championship.#{resolution.error}")
        format.turbo_stream { render "show_step" }
        format.html { render :details, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_local_vars
    if session[:season]
      @season = Season.find(session[:season])
      @league = League.find(session[:league])
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
      :match_lost_earning,
      :match_goal_earning,
      :match_goal_lost,
      :match_yellow_card_loss,
      :match_red_card_loss,
      :match_winning_ranking,
      :match_draw_ranking,
      :match_lost_ranking,
      :advertisement
    )
  end

  def award_params
    params.permit(award: {})
  end
end
