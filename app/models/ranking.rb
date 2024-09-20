class Ranking < ApplicationRecord
  belongs_to :season
  belongs_to :club
  belongs_to :source, polymorphic: true
  belongs_to :championship_award, ->{ where(rankings: { source_type: 'ChampionshipAward' })}, foreign_key: 'source_id', optional: true
  belongs_to :game, ->{ where(rankings: { source_type: 'Game' })}, foreign_key: 'source_id', optional: true
  belongs_to :season_award, ->{ where(rankings: { source_type: 'SeasonAward' })}, foreign_key: 'source_id', optional: true

  after_create :update_ranking_balance

  private

  def update_ranking_balance
    user_club = User.getClub(self.club.user_season.user.id, self.club.user_season.season_id)
    if Ranking.where(club_id: user_club.id).count > 1
      previous_balance = Ranking.where(club_id: user_club.id).order(created_at: :asc).second_to_last
      prev_balance = previous_balance.balance.nil? ? previous_balance.points : previous_balance.balance
      current = Ranking.where(club_id: user_club.id).order(created_at: :asc).last
      current.balance = prev_balance + current.points
      current.save!
    end
  end
end
