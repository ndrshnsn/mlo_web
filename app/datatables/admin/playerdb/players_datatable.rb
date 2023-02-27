class Admin::Playerdb::PlayersDatatable < ApplicationDatatable
  delegate :session, :logger, :t, :image_tag, :current_user, :translate_pscore, :translate_pkeys, :countryFlag, :admin_playerdb_player_details_path, :admin_playerdb_player_toggle_path, :stringHuman, :teamLogoURL, :admin_playerdb_player_disable_path, :admin_playerdb_player_enable_path, :dt_actionsMenu, :image_url, :content_tag, :logger, :button_to, to: :@view

  private

  def data
    players.map do |player|

      ## Nationality
      nationality = image_tag(countryFlag(player.def_country.name), height: "18", width: "24", title: stringHuman(t("defaults.countries.#{player.def_country.name}")), data: {toggle: "tooltip", placement: "top"})
      
      ## Player Name
      playerName = image_tag("#{session[:pdbprefix]}/players/#{player.platform}/#{player.details['platformid']}.png", class: "avatar-md img-thumbnail rounded-circle me-1", style: "width: 36px; height: 36px;", onerror: "this.error=null;this.src='#{image_url("/misc/generic-player.png")}';")
      playerName += player.name

      rpPOS = translate_pkeys(player.def_player_position.name, player.platform)
      position = "<div class='badge badge-#{rpPOS[1]}'>#{rpPOS[0]}</div>"
      overallRating = "<span class='stat #{translate_pscore(player.attrs["overallRating"])}'>#{player.attrs["overallRating"]}</span>"

      ## Condition
      platform = "<span style='font-weight: bold;'>#{player.platform}</span>"

      ## Active
      pStatus = player.active == true ? t('defaults.datatables.disable') : t('defaults.datatables.enable')
      pStatusIcon = player.active == true ? "close" : "check"
      pStatusConfirm = player.active == true ? t('defaults.datatables.confirm_disable') : t('defaults.datatables.confirm_enable')

      ## Actions
      dtActions = [
        {
          link: admin_playerdb_player_details_path(player.friendly_id),
          icon: "ri-information-line",
          text: t('defaults.datatables.show'),
          disabled: "",
          turbo: "data-turbo-frame='modal'"
        },
        {
          link: "javascript:;",
          icon: "ri-#{pStatusIcon}-line",
          text: pStatus,
          disabled: "",
          turbo: "data-action='click->confirm#dialog' data-controller='confirm' data-confirm-title-value='#{pStatusConfirm}' data-confirm-icon-value='warning' data-confirm-link-value='#{admin_playerdb_player_toggle_path(player.friendly_id)}' data-confirm-action-value='post'"
        }
      ]

      {
        id: player.id,
        playerName: playerName,
        age: player.age,
        height: player.height,
        nationality: nationality,
        position: position,
        overallRating: overallRating,
        platform: platform,
        active: "<i class='ri-#{player.active == true ? "check" : "close"}-line'></i>",
        DT_Actions: dt_actionsMenu(dtActions),
        DT_RowId: player.id
      }
    end
  end

  def count
    DefPlayer.count
  end

  def total_entries
    players.total_count
  end

  def players
    @players ||= fetch_players
  end

  def fetch_players
    search_string = []
      columns.each_with_index do |term, i|
        if params[:columns]["#{i}"][:searchable] == "true" && !params[:columns]["#{i}"][:search][:value].blank?
          if term == 'def_players"."active'
            search_string << "\"#{term}\" = '#{params[:columns]["#{i}"][:search][:value]}'"
          else
            search_string << "\"#{term}\" ilike '%#{params[:columns]["#{i}"][:search][:value]}%'"
          end
        end
      end

      players = DefPlayer.all.includes(:def_player_position, :def_country)
      players = players.select("def_players.*, def_players.details -> 'attrs' -> 'overallRating'")
      if sort_column == 'def_player_positions"."name'
          players = players.order("def_player_positions.order #{sort_direction}")
      elsif sort_column == 'def_players"."overallRating'
          players = players.order(Arel.sql("\"def_players\".\"details\" -> 'attrs' -> 'overallRating' #{sort_direction}"))
      else
          players = players.order(Arel.sql("\"#{sort_column}\" #{sort_direction}"))
      end
      players = players.where(search_string.join(' AND '))
      players = players.page(page).per(per_page)
      players = players.references(:player_nationality).distinct
  end

  def columns
    [
      'def_players"."name',
      'def_players"."age',
      'def_players"."height',
      'def_countries"."name',
      'def_player_positions"."name',
      'def_players"."overallRating',
      'def_players"."platform',
      'def_players"."active'
    ]
  end
end