class AppServices::Games::Earning < ApplicationService
  def initialize(game)
    @game = game
  end

  def pay
    ActiveRecord::Base.transaction do
      pay_earnings
    end
  end

  def reversal
    ActiveRecord::Base.transaction do
      reversal_earnings
    end
  end

  private

  def pay_earnings
    homeEarnings = 0
    visitorEarnings = 0
    homeDescription = []
    visitorDescription = []

    if @game.hscore.to_i > @game.vscore.to_i
      homeEarnings += @game.championship.preferences["match_winning_earning"]
      homeDescription.push("Win")
      visitorEarnings -= @game.championship.preferences["match_lost_earning"]
      visitorDescription.push("Lost")
    elsif @game.hscore.to_i < @game.vscore.to_i
      homeEarnings -= @game.championship.preferences["match_lost_earning"]
      homeDescription.push("Lost")
      visitorEarnings += @game.championship.preferences["match_winning_earning"]
      visitorDescription.push("Win")
    elsif @game.hscore.to_i == @game.vscore.to_i
      homeEarnings += @game.championship.preferences["match_draw_earning"]
      homeDescription.push("Draw")
      visitorEarnings += @game.championship.preferences["match_draw_earning"]
      visitorDescription.push("Draw")
    end

    if @game.subtype == 3
      homeDescription.push("WO")
      visitorDescription.push("WO")
    else
      homeGoals = ClubGame.where(game_id: @game.id, club_id: @game.home_id).group(:player_season_id).size
      homeGoals.each do |hGoals|
        if hGoals[1] >= 3
          homeEarnings += game.championship.preferences["hattrick_earning"]
          homeDescription.push("HatTrick[#{hGoals[0]}]")
        end
      end

      visitorGoals = ClubGame.where(game_id: @game.id, club_id: @game.visitor_id).group(:player_season_id).size
      visitorGoals.each do |vGoals|
        if vGoals[1] >= 3
          visitorEarnings += @game.championship.preferences["hattrick_earning"]
          visitorDescription.push("HatTrick[#{vGoals[0]}]")
        end
      end

      if @game.hscore.to_i > 0 && @game.subtype != 3
        homeEarnings += (@game.hscore.to_i * @game.championship.preferences["match_goal_earning"])
        homeDescription.push("Goals[#{@game.hscore}]")
        visitorEarnings -= (@game.hscore.to_i * @game.championship.preferences["match_goal_lost"])
        visitorDescription.push("GoalsAgainst[#{@game.hscore}]")
      end

      if @game.vscore.to_i > 0 && @game.subtype != 3
        visitorEarnings += (@game.vscore.to_i * @game.championship.preferences["match_goal_earning"])
        visitorDescription.push("Goals[#{@game.vscore}]")
        homeEarnings -= (@game.vscore.to_i * @game.championship.preferences["match_goal_lost"])
        homeDescription.push("GoalsAgainst[#{@game.vscore}]")
      end

      homeCards = GameCard.where(game_id: @game.id, club_id: @game.home_id)
      homeCardsY = 0
      homeCardsR = 0
      homeCards.each do |hCard|
        if hCard.ycard == true
          homeEarnings -= @game.championship.preferences["match_yellow_card_loss"]
          homeCardsY += 1
        elsif hCard.rcard == true
          homeEarnings -= @game.championship.preferences["match_red_card_loss"]
          homeCardsR += 1
        end
      end
      homeDescription.push("ycard[#{homeCardsY}]") if homeCardsY > 0
      homeDescription.push("rcard[#{homeCardsR}]") if homeCardsR > 0

      visitorCards = GameCard.where(game_id: @game.id, club_id: @game.visitor_id)
      visitorCardsY = 0
      visitorCardsR = 0
      visitorCards.each do |vCard|
        if vCard.ycard == true
          visitorEarnings -= @game.championship.preferences["match_yellow_card_loss"]
          visitorCardsY += 1
        elsif vCard.rcard == true
          visitorEarnings -= @game.championship.preferences["match_red_card_loss"]
          visitorCardsR += 1
        end
      end
      visitorDescription.push("ycard[#{visitorCardsY}]") if visitorCardsY > 0
      visitorDescription.push("rcard[#{visitorCardsR}]") if visitorCardsR > 0
    end

    home_earnings = ClubFinance.new(
      club_id: @game.home_id,
      operation: "game",
      value: homeEarnings,
      source: @game,
      description: homeDescription.join(",")
    )
    return handle_error(@game, @game&.error) unless home_earnings.save!

    visitor_earnings = ClubFinance.new(
      club_id: @game.visitor_id,
      operation: "game",
      value: visitorEarnings,
      source: @game,
      description: visitorDescription.join(",")
    )
    return handle_error(@game, @game&.error) unless visitor_earnings.save!

    OpenStruct.new(success?: true, game: @game, error: nil)
  end

  def reversal_earnings
    return handle_error(@game, @game&.error) unless ClubFinance.where(club_id: @game.home_id, source_id: @game.id).destroy_all
    return handle_error(@game, @game&.error) unless ClubFinance.where(club_id: @game.visitor_id, source_id: @game.id).destroy_all

    OpenStruct.new(success?: true, game: @game, error: nil)
  end

  def handle_error(game, error)
    OpenStruct.new(success?: false, game: @game, error: error)
  end
end
