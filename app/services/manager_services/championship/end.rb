class ManagerServices::Championship::End < ApplicationService
  def initialize(championship)
    @championship = championship
  end

  def call
    ActiveRecord::Base.transaction do
      end_championship
    end
  end

  private

  def end_championship

    case @championship.ctype
    when "league"
      end_league
    when "cup"
    when "rounds"
    end
  end

  def end_league
    not_finished_games = Game.where(championship_id: @championship.id, phase: [99,100]).where("status < ?", 3)
    if not_finished_games.size > 0
      return handle_error(@championship, "finals_not_finished")
    else
      if @championship.preferences["league_finals"] == "on"
        firstSecondGame = Game.where(championship_id: @championship.id, phase: 100, status: 3)
        firstSecondPos = AppServices::Games::CriterionResult.call(firstSecondGame.first, firstSecondGame.second, @championship.preferences["league_criterion"]).result

        thirdFourthGame = Game.where(championship_id: @championship.id, phase: 99, status: 3)
        thirdFourthPos = AppServices::Games::CriterionResult.call(thirdFourthGame.first, thirdFourthGame.second, @championship.preferences["league_criterion"]).result

        first = firstSecondPos[:win]
        second = firstSecondPos[:lost]
        third = thirdFourthPos[:win]
        fourth = thirdFourthPos[:lost]
      else
        standing = Championship.get_standing(@championship.id, 4)

        first = standing[0][:club_id]
        second = standing[1][:club_id]
        third = standing[2][:club_id]
        fourth = standing[3][:club_id]
      end

      championship_position = ChampionshipPosition.new(
        championship_id: @championship.id,
        club_id: first,
        position: 1
      )
      return handle_error(@championship, @championship&.error) unless championship_position.save!

      championship_position = ChampionshipPosition.new(
        championship_id: @championship.id,
        club_id: second,
        position: 2
      )
      return handle_error(@championship, @championship&.error) unless championship_position.save!

      championship_position = ChampionshipPosition.new(
        championship_id: @championship.id,
        club_id: third,
        position: 3
      )
      return handle_error(@championship, @championship&.error) unless championship_position.save!

      championship_position = ChampionshipPosition.new(
        championship_id: @championship.id,
        club_id: fourth,
        position: 4
      )
      return handle_error(@championship, @championship&.error) unless championship_position.save!

      return handle_error(@championship, @championship&.error) unless AppServices::Award.new("championship", @championship.id).pay()
      return handle_error(@championship, @championship&.error) unless @championship.update!(status: 100)
    end

    OpenStruct.new(success?: true, championship: @championship, error: nil)
  end

  def notify
  end

  def handle_error(championship, error)
    OpenStruct.new(success?: false, championship: championship, error: error)
  end
end
