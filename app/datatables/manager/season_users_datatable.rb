class Manager::SeasonUsersDatatable < ApplicationDatatable
  delegate :logger, :t, :manager_users_path, :manager_user_toggle_path, :manager_user_show_path, :manager_user_remove_path, :manager_season_user_players_path, :image_tag, :dt_actionsMenu, :stringHuman, :image_url, :avatarURL, :content_tag, :session, :button_to, to: :@view

  private

  def data
    users.map do |uSeason|
      stColumn = "<div class='d-flex align-items-center'>"
      stColumn += "<div class='flex-shrink-0'>"
      stColumn += link_to "#" do
        content_tag(:img, "", src: avatarURL(uSeason.user), class: "avatar-sm rounded-circle", style: "width: 32px; height: 32px;")
      end
      stColumn += "</div>"
      stColumn += "<div class='flex-grow-1 ms-2'>"
      stColumn += link_to uSeason.user.full_name, "#", class: "font-weight-bold d-block text-nowrap"
      stColumn += "<small class='text-muted'>##{uSeason.user.nickname}</small>"
      stColumn += "</div>"
      stColumn += "</div>"

      tName = image_tag("#{session[:pdbprefix]}/teams/#{(uSeason.clubs.first.def_team.name.upcase.delete(' '))}.png", style: "width: 32px; height: 32px", class: "me-1", onerror: "this.error=null;this.src='#{image_url("/misc/generic-team.png")}';")
      tName += stringHuman(uSeason.clubs.first.def_team.name)

      mDisabled = uSeason.user.preferences["fake"] == true ? "disabled" : ""
      dtActions = [
        # {
        #   link: "javascript:;",
        #   icon: "ri-#{pStatusIcon}-line",
        #   text: pStatus,
        #   disabled: mDisabled,
        #   turbo: "data-action='click->confirm#dialog' data-controller='confirm' data-confirm-title-value='#{pStatusConfirm}' data-confirm-icon-value='warning' data-confirm-text-value='#{t('defaults.datatables.manager.users_confirm_deactivate')}' data-confirm-link-value='#{manager_user_toggle_path(uSeason.user.friendly_id)}' data-confirm-action-value='post'"
        # },
        {
          link: manager_user_show_path(uSeason.user.friendly_id),
          icon: "ri-information-line",
          text: t('defaults.datatables.show'),
          disabled: mDisabled,
          turbo: "data-turbo-action='advance' data-turbo-frame='manager_users'"
        },
        {
          link: manager_season_user_players_path(id: uSeason.season.hashid, user: uSeason.user.friendly_id),
          icon: "ri-group-line",
          text: t('defaults.datatables.players'),
          disabled: "",
          turbo: "data-turbo-action='advance' data-turbo-frame='manager_users'"
        },
        {
          link: "javascript:;",
          icon: "ri-delete-bin-fill",
          text: t('defaults.datatables.delete'),
          disabled: mDisabled,
          turbo: "data-action='click->confirm#dialog' data-controller='confirm' data-confirm-title-value='#{t('defaults.datatables.confirm_remove')}' data-confirm-text-value='#{t('defaults.datatables.manager.users_confirm_removal')}' data-confirm-icon-value='warning' data-confirm-link-value='#{manager_user_remove_path(uSeason.user.friendly_id)}'"
        }
      ]

      {
        id: uSeason.user.id,
        club: tName,
        avatar: stColumn,
        DT_Actions: dt_actionsMenu(dtActions),
        DT_RowId: uSeason.user.id
      }
    end
  end

  def count
    User.count
  end

  def total_entries
    users.total_count
  end

  def users
    @users ||= fetch_users
  end

  def fetch_users
    search_string = []
    columns.each_with_index do |term, i|
      if params[:columns]["#{i}"][:searchable] == "true" && !params[:search][:value].blank?
          search_string << "\"#{term}\" ilike '%#{params[:search][:value]}%'"
      end
    end
    users = UserSeason.joins(:user, :season, :clubs).where(seasons: { id: @params[:season] })
    users = users.order(Arel.sql("\"#{sort_column}\" #{sort_direction}"))
    users = users.page(page).per(per_page)
    users = users.where(search_string.join(' AND '))
  end

  def columns
    [
      'full_name',
      'email',
      'active'
    ]
  end
end
