class User::Trades::BuyDatatable < ApplicationDatatable
  delegate :session, :logger, :t, :image_tag, :vite_image_tag, :current_user, :translate_pscore, :translate_pkeys, :get_platforms, :countryFlag, :toCurrency, :stringHuman, :teamLogoURL, :dt_actionsMenu, :image_url, :content_tag, :logger, :button_to, :trades_buy_confirm_path, to: :@view

  private

  def data
    players.map do |player|

      player_season = PlayerSeason.find_by(def_player_id: player.id, season_id: session[:season])
      season = Season.find(session[:season])

      nationality = image_tag(countryFlag(player.def_country.name), height: "12", width: "18", title: stringHuman(t("defaults.countries.#{player.def_country.name}")), data: {toggle: "tooltip", placement: "top"})

      player_name = ApplicationController.render partial: "trades/cells/player_name", locals: {session_pdbprefix: session[:pdbprefix], player: player, nationality: nationality }

      position = ApplicationController.render partial: "trades/cells/position", locals: {rpPOS: translate_pkeys(player.def_player_position.name, player.platform) }

      overall_rating = ApplicationController.render partial: "trades/cells/overall_rating", locals: {translated_class: translate_pscore(player.attrs["overallRating"]), player: player }

      player_team = if !player_season
        ApplicationController.render partial: "trades/cells/player_free"
      else
        if player_season.club_players.size == 1
          ApplicationController.render partial: "trades/cells/player_team", locals: {pSeason: player_season, session_pdbprefix: session[:pdbprefix]}
        else
          ApplicationController.render partial: "trades/cells/player_free"
        end
      end

      player_value = Money.from_cents(player.trade_value) * season.preferences['player_value_earning_relation']
      player_value = ApplicationController.render partial: "trades/cells/player_value", locals: {playerValue: player_value.format}

      dt_actions = ApplicationController.render partial: "trades/cells/actions", locals: {season: season, player_season: player_season, player: player, player_value: player_value}
      {
        id: player.id,
        playerName: player_name,
        nationality: nationality,
        position: position,
        overallRating: overall_rating,
        age: player.age,
        playerTeam: player_team,
        playerValue: player_value,
        DT_Actions: dt_actions,
        DT_RowId: player.id
      }
    end
  end

  def getPlayers(season)
    season = Season.find(season)
    
    players = DefPlayer.eager_load(:def_player_position, :def_country,[club_players: :player_season])
    players = players.where(def_players: {platform: season.preferences["raffle_platform"], active: true})
    players = players.select(
      "def_players.*, def_players.details -> 'attrs' ->> 'overallRating', COALESCE((player_seasons.salary_cents)::Integer, ((def_players.details->'attrs'->>'overallRating')::Integer * (cast(cast('1.0' as text)||cast(def_players.details->'attrs'->>'overallRating' as text) as numeric)) * 10000)) AS trade_value")
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
    #userClub = User.getClub(current_user.id, active_season)

    searchTeams = searchSellingPlayers = searchFreePlayers = false
    search_string = []
    columns.each_with_index do |term, i|
      if params[:columns]["#{i}"][:searchable] == "true" && !params[:columns]["#{i}"][:search][:value].blank?
        if term == 'def_players"."active'
          search_string << "\"#{term}\" = '#{params[:columns]["#{i}"][:search][:value]}'"
        elsif term == 'def_players"."playerTeam'
          if params[:columns]["#{i}"][:search][:value] == "-"
            searchFreePlayers = true
            @cPlayers = DefPlayer.where.not(id: ClubPlayer.joins(:player_season).where(club_id: Season.getClubs(active_season, false).pluck(:id)).pluck('player_seasons.def_player_id')).pluck(:id)
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
      having_string = "COALESCE((player_seasons.salary_cents)::Integer, ((def_players.details->'attrs'->>'overallRating')::Integer * (cast(cast('1.0' as text)||cast(def_players.details->'attrs'->>'overallRating' as text) as numeric)) * 10000)) >= #{-(params[:minPlayerValue].to_i.abs)}"
    end

    if params[:maxPlayerValue]
      having_string += " AND COALESCE((player_seasons.salary_cents)::Integer, ((def_players.details->'attrs'->>'overallRating')::Integer * (cast(cast('1.0' as text)||cast(def_players.details->'attrs'->>'overallRating' as text) as numeric)) * 10000)) <= #{params[:maxPlayerValue].to_i.abs}"
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
      players = if searchFreePlayers == true
        players.where(def_players: {id: @cPlayers})
      elsif searchSellingPlayers == true
        players.where(player_seasons: {id: @cPlayers})
      else
        players.where(player_seasons: {id: @cPlayers})
      end
    end

    players = if sort_column == 'def_player_positions"."name'
      players.order(Arel.sql("def_player_positions.order #{sort_direction}"))
    elsif sort_column == 'overallRating'
      players.order(Arel.sql("def_players.details -> 'attrs' ->> 'overallRating' #{sort_direction}"))
    elsif sort_column == 'def_players"."playerValue'
      players.order(Arel.sql("COALESCE((player_seasons.salary_cents)::Integer, #{DefPlayer.getSeasonInitialSalary(nil, nil, true)} ) #{sort_direction} nulls last"))
    elsif sort_column == 'def_players"."playerTeam'
      players.order("club_players.id #{sort_direction}")
    else
      players.order(Arel.sql("\"#{sort_column}\" #{sort_direction}"))
    end

    players = players.where(search_string.join(' AND '))
    players = players.where(having_string)

    players.page(page).per(per_page)
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
