class ManagerServices::Championship::League::Semi < ApplicationService
  def initialize(championship)
    @championship = championship
  end

  def call
    ActiveRecord::Base.transaction do
      start_league_semi
    end
  end

  private

  def start_league_semi
    not_finished_games = Game.where(championship_id: @championship.id, phase: [1,2]).where("status < ?", 3)
    if not_finished_games.size > 0
      not_finished_games.each do |game|
        if game.status > 1
          return handle_error(@championship, @championship&.error) unless ManagerServices::Championship::Standing.new(game).reversal()
        end
        return handle_error(@championship, @championship&.error) unless AppServices::Games::Revoke.call(game)
      end
    end

    next_game_sequence = Championship.get_game_sequence(@championship) + 1
    
    standing = Championship.get_standing(@championship.id, 4)
    home = standing[0][:club_id]
    visitor = standing[3][:club_id]

    first_semi = Game.new(
      championship_id: @championship.id,
      home_id: visitor,
      visitor_id: home,
      phase: 98,
      status: 0,
      gsequence: next_game_sequence
    )
    return handle_error(@championship, @championship&.error) unless first_semi.save!
    second_semi = Game.new(
      championship_id: @championship.id,
      home_id: home,
      visitor_id: visitor,
      phase: 98,
      status: 0,
      gsequence: next_game_sequence + 1
    )
    return handle_error(@championship, @championship&.error) unless second_semi.save!

    home = standing[1][:club_id]
    visitor = standing[2][:club_id]
    third_semi = Game.new(
      championship_id: @championship.id,
      home_id: visitor,
      visitor_id: home,
      phase: 98,
      status: 0,
      gsequence: next_game_sequence + 2
    )
    return handle_error(@championship, @championship&.error) unless third_semi.save!
    fourth_semi = Game.new(
      championship_id: @championship.id,
      home_id: home,
      visitor_id: visitor,
      phase: 98,
      status: 0,
      gsequence: next_game_sequence + 3
    )
    return handle_error(@championship, @championship&.error) unless fourth_semi.save!

    return handle_error(@championship, @championship&.error) unless @championship.update!(status: 13)
    OpenStruct.new(success?: true, championship: @championship, error: nil)
  end

  def notify
  end

  def handle_error(championship, error)
    OpenStruct.new(success?: false, championship: @championship, error: error)
  end
end
