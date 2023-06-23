class Manager::WaitingUsersDatatable < ApplicationDatatable
  delegate :logger, :t, :manager_users_path, :manager_user_toggle_path, :manager_user_show_path, :manager_user_remove_path, :manager_user_eseason_path, :image_tag, :dt_actionsMenu, :avatarURL, :content_tag, :session, :button_to, to: :@view

  private

  def data
    users.map.with_index do |uLeague, i|
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

      aStatus = if uLeague.status
        content_tag(:span, t("active").upcase, class: "badge badge-soft-success")
      else
        content_tag(:span, t("inactive").upcase, class: "badge badge-soft-light")
      end

      pStatus = (uLeague.status == true) ? t("defaults.datatables.disable") : t("defaults.datatables.enable")
      pStatusIcon = (uLeague.status == true) ? "close" : "check"
      pStatusConfirm = (uLeague.status == true) ? t("defaults.datatables.confirm_disable") : t("defaults.datatables.confirm_enable")

      dtActions = [
        {
          link: manager_user_eseason_path(uLeague.user.friendly_id),
          icon: "ri-#{pStatusIcon}-line",
          text: pStatus,
          disabled: "",
          turbo: "data-turbo-frame='modal'"
        },
        {
          link: manager_user_show_path(uLeague.user.friendly_id),
          icon: "ri-user-line",
          text: t("defaults.datatables.show"),
          disabled: "",
          turbo: "data-turbo-action='advance'"
        },
        {
          link: "javascript:;",
          icon: "ri-delete-bin-fill",
          text: t("defaults.datatables.delete"),
          disabled: "",
          turbo: "data-action='click->confirm#dialog' data-controller='confirm' data-confirm-title-value='#{t("defaults.datatables.confirm_remove")}' data-confirm-text-value='#{t("defaults.datatables.manager.users_confirm_removal")}' data-confirm-icon-value='warning' data-confirm-link-value='#{manager_user_remove_path(uLeague.user.friendly_id)}'"
        }
      ]

      {
        id: uLeague.user.id,
        order: i + 1,
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

    users = UserLeague.joins(:user).where(user_leagues: {league_id: session[:league], status: false})
    users = users.order(updated_at: :desc)
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
