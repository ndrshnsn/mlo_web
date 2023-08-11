class Ranking < ApplicationRecord
  belongs_to :season
  belongs_to :club
  belongs_to :source, polymorphic: true
  after_create :update_ranking_balance

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