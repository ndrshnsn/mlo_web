class Manager::ActiveUsersDatatable < ApplicationDatatable
  delegate :logger, :t, :manager_users_path, :manager_user_toggle_path, :manager_user_show_path, :manager_user_remove_path, :image_tag, :dt_actionsMenu, :avatarURL, :content_tag, :session, :button_to, to: :@view

  private

  def data
    users.map do |uLeague|
      stColumn = "<div class='d-flex align-items-center'>"
      stColumn += "<div class='flex-shrink-0'>"
      stColumn += link_to "#" do
        content_tag(:img, "", src: avatarURL(uLeague.user), class: "avatar-sm rounded-circle", style: "width: 32px; height: 32px;")
      end
      stColumn += "</div>"
      stColumn += "<div class='flex-grow-1 ms-2'>"
      stColumn += link_to uLeague.user.full_name, "#", class: "font-weight-bold d-block text-nowrap"
      stColumn += "<small class='text-muted'>##{uLeague.user.nickname}</small>"
      stColumn += "</div>"
      stColumn += "</div>"

      aStatus = uLeague.status ? content_tag(:span, t("active").upcase, class: "badge badge-soft-success") : content_tag(:span, t("inactive").upcase, class: "badge badge-soft-light")

      pStatus = (uLeague.status == true) ? t("defaults.datatables.disable") : t("defaults.datatables.enable")
      pStatusIcon = (uLeague.status == true) ? "close" : "check"
      pStatusConfirm = (uLeague.status == true) ? t("defaults.datatables.confirm_disable") : t("defaults.datatables.confirm_enable")
      mDisabled = (uLeague.user.preferences["fake"] == true) ? "disabled" : ""
      dtActions = [
        {
          link: manager_user_show_path(uLeague.user.friendly_id),
          icon: "ri-user-line",
          text: t("defaults.datatables.show"),
          disabled: mDisabled,
          turbo: "data-turbo-action='advance' data-turbo-frame='manager_users'"
        },
        {
          link: "javascript:;",
          icon: "ri-#{pStatusIcon}-line",
          text: pStatus,
          disabled: mDisabled,
          turbo: "data-action='click->confirm#dialog' data-controller='confirm' data-confirm-title-value='#{pStatusConfirm}' data-confirm-icon-value='warning' data-confirm-text-value='#{t("defaults.datatables.manager.users_confirm_deactivate")}' data-confirm-link-value='#{manager_user_toggle_path(uLeague.user.friendly_id)}' data-confirm-action-value='post'"
        }
      ]

      {
        id: uLeague.user.id,
        avatar: stColumn,
        email: uLeague.user.email,
        status: aStatus,
        DT_Actions: dt_actionsMenu(dtActions),
        DT_RowId: uLeague.user.id
      }
    end
  end

  def count
    User.count
  end

  def total_entries
    users.total_count
    # will_paginate
    # players.total_entries
  end

  def users
    @users ||= fetch_users
  end

  def fetch_users
    search_string = []
    columns.each_with_index do |term, i|
      if params[:columns]["#{i}"][:searchable] == "true" && params[:search][:value].present?
        search_string << "\"#{term}\" ilike '%#{params[:search][:value]}%'"
      end
    end
    users = UserLeague.joins(:user).where(user_leagues: {league_id: session[:league], status: true})
    users = users.order(Arel.sql("\"#{sort_column}\" #{sort_direction}"))
    users = users.page(page).per(per_page)
    users = users.where(search_string.join(" AND "))
  end

  def columns
    [
      "full_name",
      "email",
      "active"
    ]
  end
end
