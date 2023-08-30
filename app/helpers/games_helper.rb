module GamesHelper
  def players_suspended(championship, game)
    game = Game.find_by_hashid(game)
    championship = Championship.find_by_hashid(championship)
    pSuspended = {:home_ycard => [], :home_rcard => [], :visitor_ycard => [], :visitor_rcard => []}
    hPlayers =  User.getTeamPlayers(game.home.user_season.user.id, session[:season]).pluck(:player_season_id)
    hPlayersyCard = PlayerSeason.where(id: hPlayers).where("details ->> 'ycard' = '#{AppConfig.championship_cards_suspension_ycard}'").pluck(:id)
    if hPlayersyCard.count > 0
        pSuspended[:home_ycard] = hPlayersyCard
    end
    hPlayersrCard = PlayerSeason.where(id: hPlayers).where("details ->> 'rcard' = '#{AppConfig.championship_cards_suspension_rcard}'").pluck(:id)
    if hPlayersrCard.count > 0
        pSuspended[:home_rcard] = hPlayersrCard
    end
    vPlayers =  User.getTeamPlayers(game.visitor.user_season.user.id, session[:season]).pluck(:player_season_id)
    vPlayersyCard = PlayerSeason.where(id: vPlayers).where("details ->> 'ycard' = '#{AppConfig.championship_cards_suspension_ycard}'").pluck(:id)
    if vPlayersyCard.count > 0
        pSuspended[:visitor_ycard] = vPlayersyCard
    end
    vPlayersrCard = PlayerSeason.where(id: vPlayers).where("details ->> 'rcard' = '#{AppConfig.championship_cards_suspension_rcard}'").pluck(:id)
    if vPlayersrCard.count > 0
        pSuspended[:visitor_rcard] = vPlayersrCard
    end
    pSuspended
  end
end