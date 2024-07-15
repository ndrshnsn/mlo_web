class Admin::LeaguesDatatable < ApplicationDatatable
  delegate :logger, :t, :admin_leagues_path, :admin_league_edit_path, :admin_league_destroy_path, :leagueBadge, :dt_actionsMenu, :image_tag, :content_tag, :button_to, to: :@view

  private

  def data
    leagues.map do |league|
      lName = image_tag(leagueBadge(league), class: "rounded mr-50", height: "32", width: "32")
      lName += league.name

      lStatus = if league.status
        content_tag(:span, t("active"), class: "badge badge-soft-success")
      else
        content_tag(:span, t("inactive"), class: "badge badge-soft-light")
      end

      platform = league.platform

      lUsers = league.user_leagues.where(user_leagues: {status: true}).size

      dtActions = [
        {
          link: admin_league_edit_path(league.friendly_id),
          icon: "ri-edit-line",
          text: t("defaults.datatables.edit"),
          disabled: "",
          turbo: "data-turbo-action='advance'"
        },
        {
          link: "javascript:;",
          icon: "ri-delete-bin-fill",
          text: t("defaults.datatables.delete"),
          disabled: "",
          turbo: "data-action='click->confirm#dialog' data-controller='confirm' data-confirm-title-value='#{t("defaults.datatables.confirm_remove")}' data-confirm-text-value='#{t("defaults.datatables.confirm_remove_text")}' data-confirm-icon-value='warning' data-confirm-link-value='#{admin_league_destroy_path(league.friendly_id)}'"
        }
      ]

      {
        id: league.id,
        name: lName,
        status: lStatus,
        slots: league.slots,
        platform: platform,
        users: lUsers,
        DT_Actions: dt_actionsMenu(dtActions),
        DT_RowId: league.id
      }
    end
  end

  def count
    League.count
  end

  def total_entries
    leagues.total_count
  end

  def leagues
    @leagues ||= fetch_leagues
  end

  def fetch_leagues
    search_string = []
    columns.each_with_index do |term, i|
      if params[:columns]["#{i}"][:searchable] == "true" && params[:columns]["#{i}"][:search][:value].present?
        if term == "status"
          if params[:columns]["#{i}"][:search][:value] == "active"
            search_string << "status = true"
          elsif params[:columns]["#{i}"][:search][:value] == "inactive"
            search_string << "status = false"
          end
        else
          search_string << "\"#{term}\" ilike '%#{params[:columns]["#{i}"][:search][:value]}%'"
        end
      end
    end

    leagues = League.eager_load(:user_leagues)
    leagues = leagues.page(page).per(per_page)
    leagues = leagues.where(search_string.join(" AND "))
    if sort_column == "users"
      leagues = leagues.order(Arel.sql("count(user_leagues.league_id) #{sort_direction}"))
      leagues = leagues.group("leagues.id, user_leagues.id")
    elsif sort_column == "status"
      leagues = leagues.order(Arel.sql("leagues.status #{sort_direction}"))
    else
      leagues = leagues.order(Arel.sql("\"#{sort_column}\" #{sort_direction}"))
    end
  end

  def columns
    [
      "name",
      "slots",
      "users",
      "status"
    ]
  end
end
