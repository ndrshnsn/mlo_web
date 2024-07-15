class ManagerServices::Championship::League::Final < ApplicationService
  def initialize(championship)
    @championship = championship
  end

  def call
    ActiveRecord::Base.transaction do
      start_league_final
    end
  end

  private

  def start_league_final

    not_finished_games = Game.where(championship_id: @championship.id, phase: 98).where("status < ?", 3)
    if not_finished_games.size > 0
      return handle_error(@championship, "semi_not_finished") 
    else
      thome = ""
      tvisitor = ""
      finals = []

      previous_semi = Game.where(championship_id: @championship.id, phase: 98).order(created_at: :asc)
      previous_semi.each do |game|
        if game.home_id == thome || game.visitor_id == thome
          opponent_game = Game.where(championship_id: @championship.id, phase: 98, home_id: game.visitor_id, visitor_id: game.home_id).first
          
          check_game = AppServices::Games::CriterionResult.call(opponent_game, game, @championship.preferences["league_criterion"])
          finals.push(check_game.result)
        end
        thome = game.home_id
        tvisitor = game.visitor_id
      end

      next_game_sequence = Championship.get_game_sequence(@championship) + 1
      standing = Championship.get_standing(@championship.id, 4)

      thirdFourthHome = (standing.index { |el| el[:club_id] == finals[0][:lost] } < standing.index { |el| el[:club_id] == finals[1][:lost] }) ? finals[0][:lost] : finals[1][:lost]
      thirdFourthVisitor = (thirdFourthHome == finals[0][:lost]) ? finals[1][:lost] : finals[0][:lost]

      first3rd4th = Game.create(
        championship_id: @championship.id,
        home_id: thirdFourthVisitor,
        visitor_id: thirdFourthHome,
        status: 0,
        phase: 99,
        gsequence: next_game_sequence
      )
      second3rd4th = Game.create(
        championship_id: @championship.id,
        home_id: thirdFourthHome,
        visitor_id: thirdFourthVisitor,
        status: 0,
        phase: 99,
        gsequence: next_game_sequence + 1
      )

      finalHome = (standing.index { |el| el[:club_id] == finals[0][:win] } < standing.index { |el| el[:club_id] == finals[1][:win] }) ? finals[0][:win] : finals[1][:win]
      finalVisitor = (finalHome == finals[0][:win]) ? finals[1][:win] : finals[0][:win]

      firstFinal = Game.create(
        championship_id: @championship.id,
        home_id: finalVisitor,
        visitor_id: finalHome,
        status: 0,
        phase: 100,
        gsequence: next_game_sequence + 2
      )
      secondFinal = Game.create(
        championship_id: @championship.id,
        home_id: finalHome,
        visitor_id: finalVisitor,
        status: 0,
        phase: 100,
        gsequence: next_game_sequence + 3
      )
    end

    return handle_error(@championship, @championship&.error) unless @championship.update!(status: 14)
    OpenStruct.new(success?: true, championship: @championship, error: nil)
  end

  def notify
  end

  def handle_error(championship, error)
    OpenStruct.new(success?: false, championship: @championship, error: error)
  end
end
