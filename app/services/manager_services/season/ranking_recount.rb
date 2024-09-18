class ManagerServices::Season::RankingRecount < ApplicationService
  def initialize(season, user)
    @season = season
    @user = user
  end

  def call
    ActiveRecord::Base.transaction do
      ranking_recount
    end
  end

  private

  def ranking_recount
    # remove old rankings
    return handle_error(@season, @season&.error) unless Ranking.where(season_id: @season.id).delete_all

    # recreate ranking for selected season
    @season.championships.each_with_index do |championship, c|
      championship.games.each_with_index do |game, g|
        return handle_error(game, ".game_ranking_error") unless AppServices::Ranking.new(game: game).update()
      end
      
      championship_club_awards = ClubAward.joins(:championship_award).where(championship_awards: { championship_id: championship.id } )

      championship_club_awards.each do |club_award|
        ranking = Ranking.new(
          season_id: @season.id,
          club_id: club_award.club_id,
          operation: "award",
          points: club_award.source.award.ranking,
          source: club_award.source,
          description: nil
        )
        return handle_error(ranking&.error) unless ranking.save!
      end
    end

    OpenStruct.new(success?: true, season: @season, error: nil)
  end

  def handle_error(season, error)
    OpenStruct.new(success?: false, season: season, error: error)
  end
end
