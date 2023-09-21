class AppServices::Games::Start < ApplicationService
  def initialize(game, user, params)
    @game = game
    @user = user
    @params = params
  end

  def call
    ActiveRecord::Base.transaction do
      start_game
    end
  end

  private

  def start_game

    user_club = @params[:club]
    check_sequence ||= @params[:check_sequence]
    start_allowed = false
    players_start_accepted = false

    progress_status = Game.where('((home_id = ? AND visitor_id = ?) OR (home_id = ? AND visitor_id = ?)) AND championship_id = ? AND status = ?', @game.home_id, @game.visitor_id, @game.visitor_id, @game.home_id, @game.championship_id, 1).count
    progress_status_club = Game.where('(home_id = ? OR visitor_id = ?) AND championship_id = ? AND ( status >= ? AND status <= ?)', user_club, user_club, @game.championship_id, 1, 2).count
    progress_acception = Game.where(home_id: user_club, championship_id: @game.championship.id, status: 0).where('vsaccepted = ? OR hsaccepted = ?', true, true).count + Game.where(visitor_id: user_club, championship_id: @game.championship.id, status: 0).where('vsaccepted = ? OR hsaccepted = ?', true, true).count
    start_allowed = true if user_club == @game.home_id && @game.vsaccepted || user_club == @game.visitor_id && @game.hsaccepted

    if ( progress_status > 0 || progress_status_club > 0 || progress_acception == 1 ) && start_allowed == false
      return handle_error(@game, ".game_in_progress")
    else
      if check_sequence
        ordered_games = Game.where('((home_id = ? AND visitor_id = ?) OR (home_id = ? AND visitor_id = ?)) AND championship_id = ? AND phase = ? AND subtype = ?', @game.home_id, @game.visitor_id, @game.visitor_id, @game.home_id, @game.championship_id, @game.phase, @game.subtype).order(:id).first
        return handle_error(@game, ".game_in_progress") if @game.id != ordered_games.id && ordered_games.status < 3
      end
      player_side = @game.home.user_season.user.id == @user.id ? "home" : "visitor"
      if player_side == "home"
        if @game.update(hsaccepted: true)
          players_start_accepted = true if @game.vsaccepted
        end
      else
        if @game.update(vsaccepted: true)
          players_start_accepted = true if @game.hsaccepted
        end
      end
      if players_start_accepted
        return handle_error(@game, ".game_start_error") unless @game.update(status: 1)
      end
    end
    OpenStruct.new(success?: true, game: @game, error: nil)
  end

  def handle_error(game, error)
    OpenStruct.new(success?: false, game: @game, error: error)
  end
end
