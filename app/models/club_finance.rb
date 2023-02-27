class ClubFinance < ApplicationRecord
  belongs_to :club
  belongs_to :source, polymorphic: true

  after_create :update_club_balance

  ##
  # Calc new earning based on Championship Rules
  def self.updateEarnings(game, action, description = nil)
    ## Create new Entry in Club Finances
    if action == "confirm"
      # Default Earnings
      homeEarnings = 0
      visitorEarnings = 0
      homeDescription = []
      visitorDescription = []


      # Win/Lost Earning
      if game.hscore.to_i > game.vscore.to_i
        homeEarnings = homeEarnings + game.championship.preferences['match_winning_earning'].delete(',').to_i
        homeDescription.push("Win")
        visitorEarnings = visitorEarnings - game.championship.preferences['match_lost_earning'].delete(',').to_i
        visitorDescription.push("Lost")
      elsif game.hscore.to_i < game.vscore.to_i
        homeEarnings = homeEarnings - game.championship.preferences['match_lost_earning'].delete(',').to_i
        homeDescription.push("Lost")
        visitorEarnings = visitorEarnings + game.championship.preferences['match_winning_earning'].delete(',').to_i
        visitorDescription.push("Win")
      end

      # If not WO
      if game.wo == false
        # Hattrick
        homeGoals = ClubGame.where(game_id: game.id, club_id: game.home_id).group(:player_season_id).size
        homeHT = false
        homeGoals.each do |hGoals|
          if hGoals[1] >= 3
            if homeHT == false
              homeHT = true
              homeEarnings = homeEarnings + game.championship.preferences['hattrick_earning'].delete(',').to_i
              homeDescription.push("HatTrick[#{hGoals[0]}]")
            end
          end
        end

        visitorGoals = ClubGame.where(game_id: game.id, club_id: game.visitor_id).group(:player_season_id).size
        visitorHT = false
        visitorGoals.each do |vGoals|
          if vGoals[1] >= 3
            if visitorHT == false
              visitorHT = true
              visitorEarnings = visitorEarnings + game.championship.preferences['hattrick_earning'].delete(',').to_i
              visitorDescription.push("HatTrick[#{vGoals[0]}]")
            end
          end
        end

        # Draw Earning
        if game.hscore.to_i == game.vscore.to_i
          homeEarnings = homeEarnings + game.championship.preferences['match_draw_earning'].delete(',').to_i
          homeDescription.push("Draw")

          visitorEarnings = visitorEarnings + game.championship.preferences['match_draw_earning'].delete(',').to_i
          visitorDescription.push("Draw")
        end

        # Goal Earning
        if game.hscore.to_i > 0 && game.wo == false
          homeEarnings = homeEarnings + ( game.hscore.to_i * game.championship.preferences['match_goal_earning'].delete(',').to_i )
          homeDescription.push("Goals[#{game.hscore}]")

          visitorEarnings = visitorEarnings - ( game.hscore.to_i * game.championship.preferences['match_goal_lost'].delete(',').to_i )
          visitorDescription.push("GoalsAgainst[#{game.hscore}]")
        end

        if game.vscore.to_i > 0 && game.wo == false
          visitorEarnings = visitorEarnings + ( game.vscore.to_i * game.championship.preferences['match_goal_earning'].delete(',').to_i )
          visitorDescription.push("Goals[#{game.vscore}]")

          homeEarnings = homeEarnings - ( game.vscore.to_i * game.championship.preferences['match_goal_lost'].delete(',').to_i )
          homeDescription.push("GoalsAgainst[#{game.vscore}]")
        end

        # Card Loss
        homeCards = GameCard.where(game_id: game.id, club_id: game.home_id)
        homeCardsY = 0
        homeCardsR = 0
        homeCards.each do |hCard|
          if hCard.ycard == true
            homeEarnings = homeEarnings - game.championship.preferences['match_yellow_card_loss'].delete(',').to_i
            homeCardsY += 1
          elsif hCard.rcard == true
            homeEarnings = homeEarnings - game.championship.preferences['match_red_card_loss'].delete(',').to_i
            homeCardsR += 1
          end
        end
        if homeCardsY > 0
          homeDescription.push("ycard[#{homeCardsY}]")
        end
        if homeCardsR > 0
          homeDescription.push("rcard[#{homeCardsR}]")
        end

        visitorCards = GameCard.where(game_id: game.id, club_id: game.visitor_id)
        visitorCardsY = 0
        visitorCardsR = 0
        visitorCards.each do |vCard|
          if vCard.ycard == true
            visitorEarnings = visitorEarnings - game.championship.preferences['match_yellow_card_loss'].delete(',').to_i
            visitorCardsY += 1
          elsif vCard.rcard == true
            visitorEarnings = visitorEarnings - game.championship.preferences['match_red_card_loss'].delete(',').to_i
            visitorCardsR += 1
          end
        end
        if visitorCardsY > 0
          visitorDescription.push("ycard[#{visitorCardsY}]")
        end
        if visitorCardsR > 0
          visitorDescription.push("rcard[#{visitorCardsR}]")
        end

      else
        homeDescription.push("WO")
        visitorDescription.push("WO")
      end

      if description == true
        fullDescription = {
          hDesc: homeDescription,
          vDesc: visitorDescription
        }
        return fullDescription
      else

        ClubFinance.create(
          club_id: game.home_id,
          operation: "game",
          value: homeEarnings,
          source: game,
          description: homeDescription.join(",")
          )

        ClubFinance.create(
          club_id: game.visitor_id,
          operation: "game",
          value: visitorEarnings,
          source: game,
          description: visitorDescription.join(",")
          )
      end
    elsif action == "cancel"
      ClubFinance.where(club_id: game.home_id, source_id: game.id).destroy_all
      ClubFinance.where(club_id: game.visitor_id, source_id: game.id).destroy_all
    end

  end

  private
    def update_club_balance
      userClub = User.getClub(self.club.user_season.user.id, self.club.user_season.season_id)
      if ClubFinance.where(club_id: userClub.id).count > 1
        previousBalance = ClubFinance.where(club_id: userClub.id).order('updated_at ASC').second_to_last
        current = ClubFinance.where(club_id: userClub.id).order('updated_at ASC').last

        case current.operation
          when "player_hire"
            updatedBalance = previousBalance.balance - current.value
          when "pay_wage"
            updatedBalance = previousBalance.balance - current.value
          when "clear_club_balance"
            updatedBalance = current.value
          when "fire_tax"
            updatedBalance = previousBalance.balance - current.value
          when "player_steal"
            updatedBalance = previousBalance.balance - current.value
          when "player_sold"
            updatedBalance = previousBalance.balance + current.value
          when "player_stealed"
            updatedBalance = previousBalance.balance + current.value
          when "game"
            updatedBalance = previousBalance.balance + current.value
          when "award"
            updatedBalance = previousBalance.balance + current.value
        end
        current.balance = updatedBalance
        current.save!
      end
    end
end
