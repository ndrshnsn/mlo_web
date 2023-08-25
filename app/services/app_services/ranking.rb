class AppServices::Ranking < ApplicationService
  def initialize(game: nil, championship: nil)
    @game = game
    @championship = championship
  end

  def update
    ActiveRecord::Base.transaction do
      update_ranking
    end
  end

  def reversal
    ActiveRecord::Base.transaction do
      reversal_ranking
    end
  end

  private

  def update_ranking
    if @game
      homePts = 0
      visitorPts = 0
      homeDescription = []
      visitorDescription = []

      if @game.hscore.to_i > @game.vscore.to_i
        homePts = homePts + @game.championship.preferences['match_winning_ranking']
        visitorPts = visitorPts - @game.championship.preferences['match_lost_ranking']
      elsif @game.hscore.to_i < @game.vscore.to_i
        homePts = homePts - @game.championship.preferences['match_lost_ranking']
        visitorPts = visitorPts + @game.championship.preferences['match_winning_ranking']
      elsif @game.hscore.to_i == @game.vscore.to_i
        homePts = homePts + @game.championship.preferences['match_draw_ranking']
        visitorPts = visitorPts + @game.championship.preferences['match_draw_ranking']
      end

      home_ranking = Ranking.new(
        season_id: @game.championship.season.id,
        club_id: @game.home_id,
        operation: "game",
        points: homePts,
        source: @game
      )
      return handle_error(@game, @game&.error) unless home_ranking.save!

      visitor_ranking = Ranking.new(
        season_id: @game.championship.season.id,
        club_id: @game.visitor_id,
        operation: "game",
        points: visitorPts,
        source: @game
      )
      return handle_error(@game, @game&.error) unless visitor_ranking.save!
    end
    OpenStruct.new(success?: true, game: @game, error: nil)
  end

  def reversal_ranking
    if @game
      return handle_error(@game, @game&.error) unless Ranking.where(club_id: @game.home_id, source_id: @game.id).destroy_all
      return handle_error(@game, @game&.error) unless Ranking.where(club_id: @game.visitor_id, source_id: @game.id).destroy_all
    end

    OpenStruct.new(success?: true, game: @game, error: nil)
  end

  def handle_error(game, error)
    OpenStruct.new(success?: false, game: @game, error: error)
  end
end
