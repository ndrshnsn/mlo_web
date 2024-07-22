class Admin::Playerdb::TeamsDatatable < ApplicationDatatable
  delegate :logger, :t, :vite_image_tag, :vite_asset_url, :image_tag, :image_path, :countryFlag, :teamLogoURL, :admin_playerdb_team_destroy_path, :admin_playerdb_team_edit_path, :admin_playerdb_team_edit_path, :current_user, :teamBadge, :stringHuman, :dt_actionsMenu, :content_tag, :image_url, :session, :button_to, to: :@view

  private

  def data
    teams.map do |team|
      ## Team Name
      tName = image_tag("#{session[:pdbprefix]}/teams/#{team.name.upcase.delete(" ")}.png", style: "width: 32px; height: 32px", class: "me-1", onerror: "this.error=null;this.src='#{vite_asset_url("images/misc/generic-team.png")}';")
      tName += stringHuman(team.name)

      ## Platform
      tAvailable = eval(team.platforms)

      ## Country
      tCountry = image_tag(countryFlag(team.def_country.name), class: "rounded me-50", height: "18", width: "24", title: stringHuman(t("defaults.countries.#{team.def_country.name}")), data: {toggle: "tooltip", placement: "top"})

      ## Status
      tStatusClass = team.active? ? "check" : "cross"
      tStatus = content_tag(:i, "", class: "me-50 ri-#{tStatusClass}-line")

      dtActions = [
        {
          link: admin_playerdb_team_edit_path(team.friendly_id),
          icon: "ri-edit-fill",
          text: t("defaults.datatables.edit"),
          disabled: "",
          turbo: "data-turbo-action='advance'"
        },
        {
          link: "javascript:;",
          icon: "ri-close-fill",
          text: t("defaults.datatables.delete"),
          disabled: "",
          turbo: "data-action='click->confirm#dialog' data-controller='confirm' data-confirm-title-value='#{t("defaults.datatables.confirm_remove")}' data-confirm-text-value='#{t("defaults.datatables.confirm_remove_text")}' data-confirm-icon-value='warning' data-confirm-link-value='#{admin_playerdb_team_destroy_path(team.friendly_id)}'"
        }
      ]

      {
        id: team.id,
        name: tName,
        platform: tAvailable,
        country: tCountry,
        status: tStatus,
        DT_Actions: dt_actionsMenu(dtActions),
        DT_RowId: team.id
      }
    end
  end

  def count
    DefTeam.count
  end

  def total_entries
    fetch_teams.total_count
  end

  def teams
    @teams ||= fetch_teams
  end

  def fetch_teams
    search_string = []
    columns.each_with_index do |term, i|
      if params[:columns]["#{i}"][:searchable] == "true" && params[:search][:value].present?
        search_string << if term == 'def_teams"."active'
          "\"#{term}\" = '#{params[:columns]["#{i}"][:search][:value]}'"
        else
          "\"#{term}\" ilike '%#{params[:search][:value]}%'"
        end
      end
    end
    teams = DefTeam.eager_load(:def_country).order("\"#{sort_column}\" #{sort_direction}")
    teams = teams.page(page).per(per_page)
    teams = teams.where(search_string.join(" OR "))
  end

  def columns
    [
      'def_teams"."name',
      'def_teams"."platforms',
      'def_teams"."def_countries"."name',
      'def_teams"."status'
    ]
  end
end
