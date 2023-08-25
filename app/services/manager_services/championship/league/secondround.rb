class ManagerServices::Championship::League::Secondround < ApplicationService
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

    ### NOTIFY

    OpenStruct.new(success?: true, championship: @championship, error: nil)
  end

  def first_method
    @championship.preferences["secondRound_allowed_with_no_wo"] = true
    @championship.status = 11
    return handle_error(@championship, @championship&.error) unless @championship.save!
    
    ## NOTIFY!!
  end

  def second_method
    all_round_games = Game.where(championship_id: @championship.id, phase: 1)
    not_finished_games = all_round_games.where("status < ?", 3)
    if not_finished_games.size > 0
      not_finished_games.each do |game|
        return handle_error(@championship, @championship&.error) unless AppServices::Games::Revoke.call(game)
      end
    end
    return handle_error(@championship, @championship&.error) unless @championship.update!(status: 12)

    ## NOTIFY / RENDER / ACTIONCABLE
  end

  def notify

  end

  def handle_error(season, error)
    OpenStruct.new(success?: false, championship: @championship, error: error)
  end
end
