module Finance::StatementHelper

  def translate_statement_operation(value = nil, amount = nil)
    tvalues = {
      "any" => ["Todos", ""],
      "initial_funds" => ["Saldo Inicial", "+"],
      "clear_club_balance" => ["Final da Temporada", "+"],
      "pay_wage" => ["Pagamento de Salários", "-"],
      "fire_tax" => ["Multa por Demissão", "-"],
      "player_hire" => ["Novo Contrato", "-"],
      "game" => ["Partida", "+"],
      "award" => ["Premiação", "+"],
      "player_steal" => ["Roubo de Jogador", "-"],
      "player_stealed" => ["Jogador Roubado", "+"],
      "player_sold" => ["Jogador Vendido", "+"]
    }

    if value
      return tvalues[value]
    elsif amount
      return tvalues
    end
  end

  def translate_statement_source(source, source_id, statement)
    return_value = []
    case source
    when "Season"
        source_value = Season.find(source_id)
        return_value.push([source_value.name, toCurrency(statement.value)])
    when "PlayerSeason"
        source_value = PlayerSeason.find(source_id)
        playerInfo = "<img src='#{session[:pdbprefix]}/players/#{get_platforms(platform: source_value.def_player.platform, dna: true)}/#{source_value.def_player.details["platformid"]}.png' style='width: 32px; height: 32px;' class='avatar avatar-sm mr-1'> #{source_value.def_player.name}".html_safe
        return_value.push([playerInfo, toCurrency(statement.value)])

    when "Game"
        ## User Club
        @userClub = Club.find(session[:userClub], session[:session])

        ## Get Game
        source_value = Game.find(source_id)

        ## Translate ClubFinance Desc
        cfDesc = statement.description.split(",")
        if !cfDesc.index{|s| s.include?("Win")}.nil?
            return_value.push(["Vitória", toCurrency(source_value.championship.preferences['match_winning_earning'])])
        end

        if !cfDesc.index{|s| s.include?("Draw")}.nil?
            return_value.push(["Empate", toCurrency(source_value.championship.preferences['match_draw_earning'])])
        end

        if !cfDesc.index{|s| s.include?("Lost")}.nil?
            return_value.push(["Derrota", toCurrency(source_value.championship.preferences['match_lost_earning'])])
        end

        if !cfDesc.index{|s| s.include?("WO")}.nil?
            return_value.push(["WO", toCurrency(0)])
        end

        if !cfDesc.index{|s| s.include?("Goals[")}.nil?
            return_value.push(["Gols: #{cfDesc[cfDesc.index{|s| s.include?("Goals[")}].split("[").last.split("]").first}", toCurrency(cfDesc[cfDesc.index{|s| s.include?("Goals[")}].split("[").last.split("]").first.to_i * source_value.championship.preferences['match_goal_earning'])])
        end

        if !cfDesc.index{|s| s.include?("GoalsAgainst")}.nil?
            return_value.push(["Gol Sofrido: #{cfDesc[cfDesc.index{|s| s.include?("GoalsAgainst")}].split("[").last.split("]").first}", toCurrency(cfDesc[cfDesc.index{|s| s.include?("GoalsAgainst")}].split("[").last.split("]").first.to_i * source_value.championship.preferences['match_goal_lost'])])
        end

        if !cfDesc.index{|s| s.include?("ycard")}.nil?
            return_value.push(["CA: #{cfDesc[cfDesc.index{|s| s.include?("ycard")}].split("[").last.split("]").first}", toCurrency(cfDesc[cfDesc.index{|s| s.include?("ycard")}].split("[").last.split("]").first.to_i * source_value.championship.preferences['match_yellow_card_loss'])])
        end

        if !cfDesc.index{|s| s.include?("rcard")}.nil?
            return_value.push(["CV: #{cfDesc[cfDesc.index{|s| s.include?("rcard")}].split("[").last.split("]").first}", toCurrency(cfDesc[cfDesc.index{|s| s.include?("rcard")}].split("[").last.split("]").first.to_i * source_value.championship.preferences['match_red_card_loss'])])
        end

        if !cfDesc.index{|s| s.include?("HatTrick")}.nil?
            return_value.push(["HatTrick", toCurrency(source_value.championship.preferences['hattrick_earning'])])
        end
    when "Championship"
        cfDesc = statement.description.split(",")
        award = Award.find(cfDesc[0])

        championship = Championship.find(source_id)
        
        return_value.push([award.name, toCurrency(statement.value)])
    end

    return return_value
  end
  
end
