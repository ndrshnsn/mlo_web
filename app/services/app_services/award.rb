class AppServices::Award < ApplicationService
  def initialize(type = nil, id = nil)
    @type = type
    @id = id
  end

  def list_awards
    award_list
  end

  def translate
    translate_award
  end

  def pay
    ActiveRecord::Base.transaction do
      pay_awards
    end
  end

  private

  def award_list
    awards = []
    awards.push(
      { position: "firstplace", i18n: "awardTypes.firstplace", i18n_desc: "awardTypes.firstplace_desc"},
      { position: "secondplace", i18n: "awardTypes.secondplace", i18n_desc: "awardTypes.secondplace_desc"},
      { position: "thirdplace", i18n: "awardTypes.thirdplace", i18n_desc: "awardTypes.thirdplace_desc"},
      { position: "fourthplace", i18n: "awardTypes.fourthplace", i18n_desc: "awardTypes.fourthplace_desc"},
      { position: "goaler", i18n: "awardTypes.goaler", i18n_desc: "awardTypes.goaler_desc"},
      { position: "assister", i18n: "awardTypes.assister", i18n_desc: "awardTypes.assister_desc"},
      { position: "fairplay", i18n: "awardTypes.fairplay", i18n_desc: "awardTypes.fairplay_desc"},
      { position: "lessown", i18n: "awardTypes.lessown", i18n_desc: "awardTypes.lessown_desc"},
      { position: "bestplayer", i18n: "awardTypes.bestplayer", i18n_desc: "awardTypes.bestplayer_desc"}
    )
    awards
  end

  def translate_award
    self.award_list.select { |pos| pos[:position] == @type }[0]
  end

  def pay_awards
    case @type
    when "season"
    when "championship"
      @championship = Championship.find(@id)
      @championship.championship_awards.each do |championship_award|
        case championship_award.award_type
        when "firstplace"
          firstplace = @championship.championship_positions.where(position: 1).first.club_id
          award_transactions(firstplace, championship_award)
        when "secondplace"
          secondplace = @championship.championship_positions.where(position: 2).first.club_id
          award_transactions(secondplace, championship_award)
        when "thirdplace"
          thirdplace = @championship.championship_positions.where(position: 3).first.club_id
          award_transactions(thirdplace, championship_award)
        when "fourthplace"
          fourthplace = @championship.championship_positions.where(position: 4).first.club_id
          award_transactions(fourthplace, championship_award)
        when "goaler"
          goalers = Championship.getGoalers(@championship, 2)
          if goalers.length == 1 || ( goalers.size > 1 && ( goalers.first.goals > goalers.second.goals ) )
            club = ClubPlayer.where(player_season_id: goalers.first.id).first.club_id
            award_transactions(club, championship_award, goalers.first.id)
          end
        when "assister"
          assister = Championship.getAssisters(@championship, 2)
          if assister.length == 1 || ( assister.size > 1 && assister.first.assists > assister.second.assists )
            club = ClubPlayer.where(player_season_id: assister.first.id).first.club_id
            award_transactions(club, championship_award, assister.first.id)
          end
        when "fairplay"
          cCards = []
          ClubChampionship.where(championship_id: @championship.id ).each do |club|
            tCards = Game.joins(:game_cards).where(games: { championship_id: @championship.id }, game_cards: { club_id: club.club_id } ).select('games.id, game_cards.club_id, COUNT(game_cards.ycard) + COUNT(game_cards.rcard) as cards').group('games.id, game_cards.club_id')

            if tCards.length == 0
              cCards << [club.club_id, 0]
            else
              cCards << [club.club_id, tCards.first.cards]
            end
          end
          cCards = cCards.sort.sort_by{|e| e[1]}
          if cCards[0][1] < cCards[1][1]
            club = cCards[0][0]
            award_transactions(club, championship_award)
          end
        when "lessown"
          ownGoals = []
          ClubChampionship.where(championship_id: @championship.id ).each do |club|
            club_own_goals = Game.where(games: { championship_id: @championship.id, home_id: club.club_id }).sum(:vscore) + Game.where(games: { championship_id: @championship.id, visitor_id: club.club_id }).sum(:hscore)
            ownGoals << [club.club_id, club_own_goals]
          end
          result = find_unique_min_value_2d(ownGoals)
          award_transactions(ownGoals[result[:row]][0], championship_award) if !result.nil?
        when "bestplayer"
          if @championship.preferences["match_best_player"] == "on"
            bestPlayer = Championship.getBestPlayer(@championship, 2)
            if bestPlayer.length == 1 || ( bestPlayer.size > 1 && bestPlayer.first.bestplayer > bestPlayer.second.bestplayer )
              club = ClubPlayer.where(player_season_id: bestPlayer.first.id).first.club_id
              award_transactions(club, championship_award, bestPlayer.first.id)
            end
          end
        end
      end
    end
    OpenStruct.new(success?: true, error: nil)
  end

  def find_unique_min_value_2d(array_2d)
    flattened = array_2d.flatten
    min_value = flattened.min
    min_indices = flattened.each_with_index.select { |element, _| element == min_value }
    
    return nil unless min_indices.size == 1
    
    min_index = min_indices[0][1]
    row, col = min_index.divmod(array_2d[0].length)
    { value: min_value, row: row, col: col }
  end

  def award_transactions(club,award_source,desc=nil)
    club_awards = ClubAward.new(
      source: award_source,
      club_id: club,
    )
    return handle_error(club_awards&.error) unless club_awards.save!

    club_finance = ClubFinance.new(
      club_id: club,
      operation: "award",
      value: award_source.award.prize,
      source: award_source,
      description: desc
    )
    return handle_error(club_finance&.error) unless club_finance.save!

    ranking = Ranking.new(
      season_id: @championship.season_id,
      club_id: club,
      operation: "award",
      points: award_source.award.ranking,
      source: award_source,
      description: desc
    )
    return handle_error(ranking&.error) unless ranking.save!
  end

  def handle_error(error)
    OpenStruct.new(success?: false, error: error)
  end

end