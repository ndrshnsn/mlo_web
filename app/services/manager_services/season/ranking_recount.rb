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
        description = nil
        case club_award.source.award_type
        when "goaler"
          goalers = Championship.getGoalers(championship, 2)
          if goalers.length == 1 || ( goalers.size > 1 && ( goalers.first.goals > goalers.second.goals ) )
            description = goalers.first.id
          end
        when "assister"
          assister = Championship.getAssisters(championship, 2)
          if assister.length == 1 || ( assister.size > 1 && assister.first.assists > assister.second.assists )
            description = assister.first.id
          end
        when "bestplayer"
          if championship.preferences["match_best_player"] == "on"
            bestPlayer = Championship.getBestPlayer(championship, 2)
            if bestPlayer.length == 1 || ( bestPlayer.size > 1 && bestPlayer.first.bestplayer > bestPlayer.second.bestplayer )
              description = bestPlayer.first.id
            end
          end
        end 
        
        ranking = Ranking.new(
          season_id: @season.id,
          club_id: club_award.club_id,
          operation: "award",
          points: club_award.source.award.ranking,
          source: club_award.source,
          description: description
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


