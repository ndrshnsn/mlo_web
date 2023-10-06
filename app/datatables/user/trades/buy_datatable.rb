class User::Trades::BuyDatatable < ApplicationDatatable
  delegate :session, :logger, :t, :image_tag, :current_user, :translate_pscore, :translate_pkeys, :get_platforms, :countryFlag, :toCurrency, :stringHuman, :teamLogoURL, :dt_actionsMenu, :image_url, :content_tag, :logger, :button_to, :trades_buy_confirm_path, to: :@view

  private

  def data
    players.map do |player|

      pSeason = PlayerSeason.find_by(def_player_id: player.id, season_id: session[:season])
      season = Season.find(session[:season])

      nationality = image_tag(countryFlag(player.def_country.name), height: "12", width: "18", title: stringHuman(t("defaults.countries.#{player.def_country.name}")), data: {toggle: "tooltip", placement: "top"})

      playerName = ApplicationController.render partial: "trades/cells/player_name", locals: {session_pdbprefix: session[:pdbprefix], player: player, nationality: nationality }

      position = ApplicationController.render partial: "trades/cells/position", locals: {rpPOS: translate_pkeys(player.def_player_position.name, player.platform) }

      overallRating = ApplicationController.render partial: "trades/cells/overall_rating", locals: {translated_class: translate_pscore(player.attrs["overallRating"]), player: player }
      
      if !pSeason
        playerTeam = ApplicationController.render partial: "trades/cells/player_free"
      else
        if pSeason.club_players.size == 1
          playerTeam = ApplicationController.render partial: "trades/cells/player_team", locals: {pSeason: pSeason, session_pdbprefix: session[:pdbprefix]}
        else
          playerTeam = ApplicationController.render partial: "trades/cells/player_free"
        end
      end

      ## PlayerValue
      playerValue = pSeason != nil ? PlayerSeason.getPlayerPass(pSeason, season) : DefPlayer.getSeasonInitialSalary(season, player)* season.preferences["player_value_earning_relation"]
      playerValue = ApplicationController.render partial: "trades/cells/player_value", locals: { playerValue: playerValue }

      ## Actions
      dtActions = ApplicationController.render partial: "trades/cells/actions", locals: {player: player}

      {
        id: player.id,
        playerName: playerName,
        nationality: nationality,
        position: position,
        overallRating: overallRating,
        age: player.age,
        playerTeam: playerTeam,
        playerValue: playerValue,
        DT_Actions: dtActions,
        DT_RowId: player.id
      }
    end
  end

  def getPlayers(season)
    season = Season.find(season)
    players = DefPlayer.eager_load(:def_player_position, :def_country, :club_players)
    players = players.select("def_players.*, player_seasons.details -> 'salary', def_players.details -> 'attrs' ->> 'overallRating'")
    players = players.where(def_players: { platform: season.preferences["raffle_platform"], active: true } )
    players
  end

  def count
    getPlayers(session[:season]).count
  end

  def total_entries
    players.total_count
  end

  def players
    @players ||= fetch_players
  end

  def fetch_players
    active_season = session[:season]
    userClub = User.getClub(current_user.id, active_season)

    searchTeams = searchSellingPlayers = searchFreePlayers = false
    search_string = []
    columns.each_with_index do |term, i|
      if params[:columns]["#{i}"][:searchable] == "true" && !params[:columns]["#{i}"][:search][:value].blank?
        if term == 'def_players"."active'
          search_string << "\"#{term}\" = '#{params[:columns]["#{i}"][:search][:value]}'"
        elsif term == 'def_players"."playerTeam'
          if params[:columns]["#{i}"][:search][:value] == "-"
            searchFreePlayers = true
            @cPlayers = ClubPlayer.joins(:player_season, :def_players).where(player_seasons: { season_id: active_season } ).pluck('def_players.id')
          else
            @cPlayers = Club.joins(:club_players).where(clubs: { id: params[:columns]["#{i}"][:search][:value] }).pluck('club_players.player_season_id')
          end
          searchTeams = true
        elsif term == 'overallRating'
        elsif term == 'def_countries"."id'
          search_string << "\"#{term}\" = '#{params[:columns]["#{i}"][:search][:value]}'"
        else
          search_string << "\"#{term}\" ilike '%#{params[:columns]["#{i}"][:search][:value]}%'"
        end
      end
    end

    players = getPlayers(active_season)

    if params[:minPlayerValue]
      having_string = "COALESCE((player_seasons.details->'salary')::Integer, #{DefPlayer.getSeasonInitialSalary(nil, nil, true)} ) >= #{params[:minPlayerValue].to_i.abs}"
    end

    if params[:maxPlayerValue]
      having_string += " AND COALESCE((player_seasons.details->'salary')::Integer, #{DefPlayer.getSeasonInitialSalary(nil, nil, true)} ) <= #{params[:maxPlayerValue].to_i.abs}"
    end

    if params[:minAge]
      search_string << "\"age\" >= #{params[:minAge].to_i.abs}"
    end

    if params[:maxAge]
      search_string << "\"age\" <= #{params[:maxAge].to_i.abs}"
    end

    if params[:minOverall]
      players = players.where("(def_players.details -> 'attrs' ->> 'overallRating')::Integer >= ?", params[:minOverall].to_i.abs)
    end

    if params[:maxOverall]
      players = players.where("(def_players.details -> 'attrs' ->> 'overallRating')::Integer <= ?", params[:maxOverall].to_i.abs)
    end

    if searchTeams == true
      if searchFreePlayers == true
        players = players.where('def_players.id NOT IN (?)', @cPlayers)
      elsif searchSellingPlayers == true
        players = players.where('player_seasons.id IN (?)', @cPlayers)
      else
        players = players.where('player_seasons.id IN (?)', @cPlayers)
      end
    end

    if sort_column == 'def_player_positions"."name'
      players = players.order(Arel.sql("def_player_positions.order #{sort_direction}"))
    elsif sort_column == 'overallRating'
      players = players.order(Arel.sql("def_players.details -> 'attrs' ->> 'overallRating' #{sort_direction}"))
    elsif sort_column == 'def_players"."playerValue'
      players = players.order(Arel.sql("COALESCE((player_seasons.details->'salary')::Integer, #{DefPlayer.getSeasonInitialSalary(nil, nil, true)} ) #{sort_direction} nulls last"))
    elsif sort_column == 'def_players"."playerTeam'
      players = players.order("club_players.id #{sort_direction}")
    else
      players = players.order(Arel.sql("\"#{sort_column}\" #{sort_direction}"))
    end

    players = players.where(search_string.join(' AND '))
    players = players.where(having_string)
    players = players.page(page).per(per_page)
  end

  def columns
    [
      'def_players"."name',
      'def_player_positions"."name',
      'overallRating',
      'def_players"."playerTeam',
      'def_players"."playerValue',
      'def_countries"."id'
    ]
  end
end
