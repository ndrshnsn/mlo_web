class Ranking < ApplicationRecord
  belongs_to :season
  belongs_to :club
  belongs_to :source, polymorphic: true
  after_create :update_ranking_balance

  ##
  # Calc Ranking Points based on Championship Rule
  def self.updateRanking(game, action)
    ## Create new Entry in Ranking Table
    if action == "confirm"
      # Default Earnings
      homePts = 0
      visitorPts = 0
      homeDescription = []
      visitorDescription = []

      if game.wo == false
        # Draw Earning
        if game.hscore.to_i == game.vscore.to_i
          homePts = homePts + game.championship.preferences['match_draw_ranking'].delete(',').to_i
          homeDescription.push("Draw")

          visitorPts = visitorPts + game.championship.preferences['match_draw_ranking'].delete(',').to_i
          visitorDescription.push("Draw")
        end

        # Win/Lost Earning
        if game.hscore.to_i > game.vscore.to_i
          homePts = homePts + game.championship.preferences['match_winning_ranking'].delete(',').to_i
          homeDescription.push("Win")
          visitorPts = visitorPts - game.championship.preferences['match_lost_ranking'].delete(',').to_i
          visitorDescription.push("Lost")
        elsif game.hscore.to_i < game.vscore.to_i
          homePts = homePts - game.championship.preferences['match_lost_ranking'].delete(',').to_i
          visitorPts = visitorPts + game.championship.preferences['match_winning_ranking'].delete(',').to_i
        end

        Ranking.create(
          season_id: game.championship.season.id,
          club_id: game.home_id,
          operation: "game",
          points: homePts,
          source: game
          )

        Ranking.create(
          season_id: game.championship.season.id,
          club_id: game.visitor_id,
          operation: "game",
          points: visitorPts,
          source: game
          )
      end
    elsif action == "cancel"
      Ranking.where(club_id: game.home_id, source_id: game.id).destroy_all
      Ranking.where(club_id: game.visitor_id, source_id: game.id).destroy_all
    end

  end

  private
    def update_ranking_balance
      userClub = User.getClub(self.club.user_season.user.id, self.club.user_season.season_id)
      if Ranking.where(club_id: userClub.id).count > 1
        previousBalance = Ranking.where(club_id: userClub.id).order(created_at: :asc).second_to_last
        prevBalance = previousBalance.balance.nil? ? previousBalance.points : previousBalance.balance
        current = Ranking.where(club_id: userClub.id).order(created_at: :asc).last
        current.balance = prevBalance + current.points
        current.save!
      end
    end
end