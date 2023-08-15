class AppServices::Award < ApplicationService
  def initialize(**kwargs)
  end

  def list_awards
    award_list
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
      { position: "lessown", i18n: "awardTypes.lessown", i18n_desc: "awardTypes.lessown_desc"}
    )
    awards
  end


  ## Update Prizes based on Selected Champ Awards
  def self.updatePrizes(championship, action)
    awards = championship.preferences["award"]
    awards.each do |award|
      # Check if award was selected to be present at
      # Championship creation
      if award[1] == "on"
        # Get Award information
        aInfo = Award.find(award[0])

        case aInfo.name
        when "1o Lugar"
          # Ok, search for Champ 1st Place Club
          first = ChampionshipPosition.where(championship_id: championship.id, position: 1)

          if action == "confirm"
            # Create the Champ Award
            ChampionshipAward.where(
                championship_id: championship.id,
                club_id: first.first.club_id,
                award_id: aInfo.id
              ).first_or_create!

            # Distribute Prize
            ClubFinance.create(
                club_id: first.first.club_id,
                operation: "award",
                value: aInfo.preferences["prize"].to_i,
                source: championship,
                description: aInfo.id
              )

            # Update Ranking
            Ranking.create(
                season_id: championship.season_id,
                club_id: first.first.club_id,
                operation: "award",
                points: aInfo.preferences["ranking"].to_i,
                source: championship,
                description: aInfo.id
              )
          elsif action == "cancel"
            if first.size > 0
              ## Remove ChampionshipAward
              ChampionshipAward.where(championship_id: championship.id, club_id: first.first.club_id, award_id: aInfo.id).destroy_all

              ## Update Club Finance
              ClubFinance.where(club_id: first.first.club_id, source_id: championship.id, description: aInfo.id).destroy_all

              ## Update Ranking
              Ranking.where(club_id: first.first.club_id, source_id: championship.id, description: aInfo.id).destroy_all
            end
          end

        when "2o Lugar"
          # Ok, search for Champ 2nd Place Club
          second = ChampionshipPosition.where(championship_id: championship.id, position: 2)

          if action == "confirm"
            # Create the Champ Award
            ChampionshipAward.where(
                championship_id: championship.id,
                club_id: second.first.club_id,
                award_id: aInfo.id
              ).first_or_create!

            # Distribute Prize
            ClubFinance.create(
                club_id: second.first.club_id,
                operation: "award",
                value: aInfo.preferences["prize"].to_i,
                source: championship,
                description: aInfo.id
              )

            # Update Ranking
            Ranking.create(
                season_id: championship.season_id,
                club_id: second.first.club_id,
                operation: "award",
                points: aInfo.preferences["ranking"].to_i,
                source: championship,
                description: aInfo.id
              )
          elsif action == "cancel"
            if second.size > 0
              ## Remove ChampionshipAward
              ChampionshipAward.where(championship_id: championship.id, club_id: second.first.club_id, award_id: aInfo.id).destroy_all

              ## Update Club Finance
              ClubFinance.where(club_id: second.first.club_id, source_id: championship.id, description: aInfo.id).destroy_all

              ## Update Ranking
              Ranking.where(club_id: second.first.club_id, source_id: championship.id, description: aInfo.id).destroy_all
            end
          end

        when "3o Lugar"
          # Ok, search for Champ 3rd Place Club
          third = ChampionshipPosition.where(championship_id: championship.id, position: 3)

          if action == "confirm"
            # Create the Champ Award
            ChampionshipAward.where(
                championship_id: championship.id,
                club_id: third.first.club_id,
                award_id: aInfo.id
              ).first_or_create!

            # Distribute Prize
            ClubFinance.create(
                club_id: third.first.club_id,
                operation: "award",
                value: aInfo.preferences["prize"].to_i,
                source: championship,
                description: aInfo.id
              )

            # Update Ranking
            Ranking.create(
                season_id: championship.season_id,
                club_id: third.first.club_id,
                operation: "award",
                points: aInfo.preferences["ranking"].to_i,
                source: championship,
                description: aInfo.id
              )
          elsif action == "cancel"
            if third.size > 0
              ## Remove ChampionshipAward
              ChampionshipAward.where(championship_id: championship.id, club_id: third.first.club_id, award_id: aInfo.id).destroy_all

              ## Update Club Finance
              ClubFinance.where(club_id: third.first.club_id, source_id: championship.id, description: aInfo.id).destroy_all

              ## Update Ranking
              Ranking.where(club_id: third.first.club_id, source_id: championship.id, description: aInfo.id).destroy_all
            end
          end

        when "Goleador"
          # Get Championship Goaler
          goalers = Championship.getGoalers(championship)

          if goalers.length == 1 || ( goalers.size > 1 && ( goalers.first.goals > goalers.second.goals ) )
            # Find Club 
            club = ClubPlayer.where(player_season_id: goalers.first.id).first

            if action == "confirm"
              # Create the Champ Award
              ChampionshipAward.where(
                  championship_id: championship.id,
                  club_id: club.club_id,
                  award_id: aInfo.id
                ).first_or_create!

              # Distribute Prize
              ClubFinance.create(
                  club_id: club.club_id,
                  operation: "award",
                  value: aInfo.preferences["prize"].to_i,
                  source: championship,
                  description: "#{aInfo.id}, #{goalers.first.id}"
                )

              # Update Ranking
              Ranking.create(
                  season_id: championship.season_id,
                  club_id: club.club_id,
                  operation: "award",
                  points: aInfo.preferences["ranking"].to_i,
                  source: championship,
                  description: "#{aInfo.id}, #{goalers.first.id}"
                )
            elsif action == "cancel"
              ## Get Club Info
              club = ChampionshipAward.where(championship_id: championship.id, award_id: aInfo.id).first

              if club
                ## Remove ChampionshipAward
                ChampionshipAward.where(championship_id: championship.id, award_id: aInfo.id).destroy_all

                ## Update Club Finance
                ClubFinance.where(club_id: club.club_id, source_id: championship.id, description: "#{aInfo.id}, #{goalers.first.id}").destroy_all

                ## Update Ranking
                Ranking.where(club_id: club.club_id, source_id: championship.id, description: "#{aInfo.id}, #{goalers.first.id}").destroy_all
              end
            end
          end
        when "Assistências"
          # Get Assister
          assister = Championship.getAssisters(championship)

          if assister.length == 1 || ( assister.size > 1 && assister.first.assists > assister.second.assists )
            # Find Club 
            club = ClubPlayer.where(player_season_id: assister.first.id).first

            if action == "confirm"
              # Create the Champ Award
              ChampionshipAward.where(
                  championship_id: championship.id,
                  club_id: club.club_id,
                  award_id: aInfo.id
                ).first_or_create!

              # Distribute Prize
              ClubFinance.create(
                  club_id: club.club_id,
                  operation: "award",
                  value: aInfo.preferences["prize"].to_i,
                  source: championship,
                  description: "#{aInfo.id}, #{assister.first.id}"
                )

              # Update Ranking
              Ranking.create(
                  season_id: championship.season_id,
                  club_id: club.club_id,
                  operation: "award",
                  points: aInfo.preferences["ranking"].to_i,
                  source: championship,
                  description: "#{aInfo.id}, #{assister.first.id}"
                )
            elsif action == "cancel"
              ## Get Club Info
              club = ChampionshipAward.where(championship_id: championship.id, award_id: aInfo.id).first

              if club
                ## Remove ChampionshipAward
                ChampionshipAward.where(championship_id: championship.id, club_id: club.club_id, award_id: aInfo.id).destroy_all

                ## Update Club Finance
                ClubFinance.where(club_id: club.club_id, source_id: championship.id, description: "#{aInfo.id}, #{assister.first.id}").destroy_all

                ## Update Ranking
                Ranking.where(club_id: club.club_id, source_id: championship.id, description: "#{aInfo.id}, #{assister.first.id}").destroy_all
              end
            end
          end
        when "FairPlay"
          # Get Club with Less Cards in whole Championship
          cCards = []
          ClubChampionship.where(championship_id: championship.id ).each do |club|
            tCards = Game.joins(:game_cards).where(games: { championship_id: championship.id }, game_cards: { club_id: club.club_id } ).select('games.id, game_cards.club_id, COUNT(game_cards.ycard) + COUNT(game_cards.rcard) as cards').group('games.id, game_cards.club_id')

            if tCards.length == 0
              cCards << [club.club_id, 0]
            else
              cCards << [club.club_id, tCards.first.cards]
            end
          end

          ## Order Array
          cCards = cCards.sort.sort_by{|e| e[1]}

          if cCards[0][1] < cCards[1][1]
            # Find Club 
            club = Club.find(cCards[0][0])

            if action == "confirm"
              # Create the Champ Award
              ChampionshipAward.where(
                  championship_id: championship.id,
                  club_id: club.id,
                  award_id: aInfo.id
                ).first_or_create!

              # Distribute Prize
              ClubFinance.create(
                  club_id: club.id,
                  operation: "award",
                  value: aInfo.preferences["prize"].to_i,
                  source: championship,
                  description: aInfo.id
                )

              # Update Ranking
              Ranking.create(
                  season_id: championship.season_id,
                  club_id: club.id,
                  operation: "award",
                  points: aInfo.preferences["ranking"].to_i,
                  source: championship,
                  description: aInfo.id
                )
            elsif action == "cancel"
              ## Get Club Info
              club = ChampionshipAward.where(championship_id: championship.id, award_id: aInfo.id).first

              if club
                ## Remove ChampionshipAward
                ChampionshipAward.where(championship_id: championship.id, club_id: club.id, award_id: aInfo.id).destroy_all

                ## Update Club Finance
                ClubFinance.where(club_id: club.id, source_id: championship.id, description: aInfo.id).destroy_all

                ## Update Ranking
                Ranking.where(club_id: club.club_id, source_id: championship.id, description: aInfo.id).destroy_all
              end
            end
          end
        when "Melhor Jogador"
          if championship.preferences["match_best_player"] == "on"
            # Get Club with best player listed more times
            bestPlayer = Championship.getBestPlayer(championship)

            if bestPlayer.length == 1 || ( bestPlayer.size > 1 && bestPlayer.first.bestplayer > bestPlayer.second.bestplayer )
              # Find Club 
              club = ClubPlayer.where(player_season_id: bestPlayer.first.id).first

              if action == "confirm"
                # Create the Champ Award
                ChampionshipAward.where(
                    championship_id: championship.id,
                    club_id: club.club_id,
                    award_id: aInfo.id
                  ).first_or_create!

                # Distribute Prize
                ClubFinance.create(
                    club_id: club.club_id,
                    operation: "award",
                    value: aInfo.preferences["prize"].to_i,
                    source: championship,
                    description: "#{aInfo.id}, #{bestPlayer.first.id}"
                  )

                # Update Ranking
                Ranking.create(
                    season_id: championship.season_id,
                    club_id: club.club_id,
                    operation: "award",
                    points: aInfo.preferences["ranking"].to_i,
                    source: championship,
                    description: "#{aInfo.id}, #{bestPlayer.first.id}"
                  )
              elsif action == "cancel"
                ## Get Club Info
                club = ChampionshipAward.where(championship_id: championship.id, award_id: aInfo.id).first

                if club
                  ## Remove ChampionshipAward
                  ChampionshipAward.where(championship_id: championship.id, club_id: club.club_id, award_id: aInfo.id).destroy_all

                  ## Update Club Finance
                  ClubFinance.where(club_id: club.club_id, source_id: championship.id, description: "#{aInfo.id}, #{bestPlayer.first.id}").destroy_all

                  ## Update Ranking
                  Ranking.where(club_id: club.club_id, source_id: championship.id, description: "#{aInfo.id}, #{bestPlayer.first.id}").destroy_all
                end
              end
            end
          end
        end
      end
    end
  end

end