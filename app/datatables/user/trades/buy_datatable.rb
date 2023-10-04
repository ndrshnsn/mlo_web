class User::Trades::BuyDatatable < ApplicationDatatable
  delegate :session, :logger, :t, :image_tag, :current_user, :translate_pscore, :translate_pkeys, :get_platforms, :countryFlag, :toCurrency, :stringHuman, :teamLogoURL, :dt_actionsMenu, :image_url, :content_tag, :logger, :button_to, :trades_buy_confirm_path, to: :@view

  private

  def data
    players.map do |player|

      pSeason = PlayerSeason.find_by(def_player_id: player.id, season_id: session[:season])
      season = Season.find(session[:season])

      ## Nationality
      nationality = image_tag(countryFlag(player.def_country.name), height: "12", width: "18", title: stringHuman(t("defaults.countries.#{player.def_country.name}")), data: {toggle: "tooltip", placement: "top"})

      ## Player Name
      playerName = "<div class='d-flex align-items-center'>"
      playerName += "<div class='flex-shrink-0'>"
      playerName += image_tag("#{session[:pdbprefix]}/players/#{get_platforms(platform: player.platform, dna: true)}/#{player.details["platformid"]}.png", class: "avatar-md img-thumbnail rounded-circle", style: "width: 36px; height: 36px;", onerror: "this.error=null;this.src='#{image_url("/misc/generic-player.png")}';")
      playerName += "</div><div class='flex-grow-1 ms-2 text-start'>"
      playerName += "<span class='font-weight-bold d-block text-nowrap'>#{player.name}</span>"

      playerName += "<small class='d-flex text-muted mb-0'>"
      playerName += "<div class='d-flex align-items-center'>"
      playerName += "<div class='flex-shrink-0'>#{nationality}</div>"
      playerName += "<div class='flex-grow-1 ms-1 text-start'>Idade #{player.age} / Altura #{player.height}</div>"

      playerName += "</div></small>"
      playerName += "</div></div>"

      rpPOS = translate_pkeys(player.def_player_position.name, player.platform)
      position = "<div class='badge badge-#{rpPOS[1]}'>#{rpPOS[0]}</div>"
      overallRating = "<span class='stat #{translate_pscore(player.attrs["overallRating"])}'>#{player.attrs["overallRating"]}</span>"

      if !pSeason
        playerTeam = "<div class='badge badge-dark'>LIVRE</span>"
      else
        if pSeason.club_players.size == 1
          playerTeam = "<div class='d-flex align-items-center'>"
          playerTeam += "<div class='flex-shrink-0'>"
          playerTeam += image_tag("#{session[:pdbprefix]}/teams/#{(pSeason.club_players[0].club.def_team.name.upcase.delete(' '))}.png", class: "avatar-xs", onerror: "this.error=null;this.src='#{image_url("generic-club.png")}';")
          playerTeam += "</div><div class='flex-grow-1 ms-2 text-start'>"
          playerTeam += "<span class='font-weight-bold d-block text-nowrap'>#{pSeason.club_players[0].club.def_team.details['teamAbbr']}</span>"
          playerTeam += "<span class='text-muted'>##{pSeason.club_players[0].club.user_season.user.nickname}</span>"
          playerTeam += "</div></div>"
        else
          playerTeam = "<div class='badge badge-dark'>#{t('.free')}</span>"
        end
      end

      ## PlayerValue
      if pSeason != nil
        playerValue = PlayerSeason.getPlayerPass(pSeason, season)
        playerValueOnly = playerValue
        playerValue = toCurrency(playerValue)
      else
        playerValue = DefPlayer.getSeasonInitialSalary(season, player)* season.preferences["player_value_earning_relation"]
        playerValueOnly = playerValue
        playerValue = toCurrency(playerValue)
      end

      ## Actions
      dtActions = [
        {
          link: player.friendly_id,
          icon: "ri-information-line",
          text: t("defaults.datatables.show"),
          disabled: "",
          turbo: "data-turbo-frame='modal'"
        },
        {
          link: "javascript:;",
          icon: "ri-shopping-cart-line",
          text: t("defaults.datatables.buy"),
          disabled: "",
          turbo: "data-action='click->confirm#dialog' data-controller='confirm' data-confirm-title-value='#{t('defaults.datatables.buy_question')}' data-confirm-icon-value='question' data-confirm-link-value='#{trades_buy_confirm_path}' data-confirm-action-value='post'"
        }
      ]

      {
        id: player.id,
        playerName: playerName,
        nationality: nationality,
        position: position,
        overallRating: overallRating,
        age: player.age,
        playerTeam: playerTeam,
        playerValue: playerValue,
        playerValueOnly: playerValueOnly,
        DT_Actions: dt_actionsMenu(dtActions),
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
