class ManagerServices::Championship::Standing < ApplicationService
  def initialize(game, params = nil)
    @game = game
    @params = params if params
  end

  def update
    ActiveRecord::Base.transaction do
      update_standing
    end
  end

  def reversal
    ActiveRecord::Base.transaction do
      reversal_standing
    end
  end

  private

  def update_standing

    home = ClubChampionship.find_by(club_id: @game.home_id, championship_id: @game.championship_id)
    home.games += 1
    home.goalsfor += @game.hscore
    home.goalsagainst += @game.vscore
    home.goalsdiff = (home.goalsfor) - (home.goalsagainst)

    visitor = ClubChampionship.find_by(club_id: @game.visitor_id, championship_id: @game.championship_id)
    visitor.games += 1
    visitor.goalsfor += @game.vscore
    visitor.goalsagainst += @game.hscore
    visitor.goalsdiff = (visitor.goalsfor) - (visitor.goalsagainst)

    if @game.hscore > @game.vscore
      home.wins += 1
      home.points += AppConfig.match_winning_points
      visitor.losses += 1
      visitor.points += AppConfig.match_lost_points
    elsif @game.hscore == @game.vscore
      home.draws += 1
      home.points += AppConfig.match_draw_points
      visitor.draws += 1
      visitor.points += AppConfig.match_draw_points
    elsif @game.vscore > @game.hscore
      home.losses += 1
      home.points += AppConfig.match_lost_points
      visitor.wins += 1
      visitor.points += AppConfig.match_winning_points
    end

    club_games = Game.where(championship_id: @game.championship_id, status: 3)
    club_games = club_games.where(group: @params[:group]) if !@params.nil?

    home_club_games = club_games.where("home_id = ? OR visitor_id = ?", @game.home_id, @game.home_id)
    home.gamerate = home.games == 0 ? 0 : ((home.points * 100) / (home_club_games.size * AppConfig.match_winning_points)).round(2)

    visitor_club_games = club_games.where("home_id = ? OR visitor_id = ?", @game.visitor_id, @game.visitor_id)
    visitor.gamerate = visitor.games == 0 ? 0 : ((visitor.points * 100) / (visitor_club_games.size * AppConfig.match_winning_points)).round(2)

    return handle_error(@game, @game&.error) unless home.save!
    return handle_error(@game, @game&.error) unless visitor.save!

    OpenStruct.new(success?: true, game: @game, error: nil)
  end

  def reversal_standing

    home = ClubChampionship.find_by(club_id: @game.home_id, championship_id: @game.championship_id)
    home.games -= 1
    home.goalsfor -= @game.hscore
    home.goalsagainst -= @game.vscore
    home.goalsdiff = (home.goalsfor) - (home.goalsagainst)

    visitor = ClubChampionship.find_by(club_id: @game.visitor_id, championship_id: @game.championship_id)
    visitor.games -= 1
    visitor.goalsfor -= @game.vscore
    visitor.goalsagainst -= @game.hscore
    visitor.goalsdiff = (visitor.goalsfor) - (visitor.goalsagainst)

    if @game.hscore > @game.vscore
      home.wins -= 1
      home.points -= AppConfig.match_winning_points
      visitor.losses -= 1
      visitor.points -= AppConfig.match_lost_points
    elsif @game.hscore == @game.vscore
      home.draws -= 1
      home.points -= AppConfig.match_draw_points
      visitor.draws -= 1
      visitor.points -= AppConfig.match_draw_points
    elsif @game.vscore > @game.hscore
      home.losses -= 1
      home.points -= AppConfig.match_lost_points
      visitor.wins -= 1
      visitor.points -= AppConfig.match_winning_points
    end

    club_games = Game.where(championship_id: @game.championship_id, status: 3).where.not(id: @game.id)
    club_games = club_games.where(group: @params[:group]) if !@params.nil?

    home_club_games = club_games.where("home_id = ? OR visitor_id = ?", @game.home_id, @game.home_id)
    home.gamerate = home.games == 0 ? 0 : ((home.points * 100) / (home_club_games.size * AppConfig.match_winning_points)).round(2)

    visitor_club_games = club_games.where("home_id = ? OR visitor_id = ?", @game.visitor_id, @game.visitor_id)
    visitor.gamerate = visitor.games == 0 ? 0 : ((visitor.points * 100) / (visitor_club_games.size * AppConfig.match_winning_points)).round(2)

    return handle_error(@game, @game&.error) unless home.save!
    return handle_error(@game, @game&.error) unless visitor.save!

    OpenStruct.new(success?: true, game: @game, error: nil)
  end

  def handle_error(game, error)
    OpenStruct.new(success?: false, game: game, error: error)
  end
end
