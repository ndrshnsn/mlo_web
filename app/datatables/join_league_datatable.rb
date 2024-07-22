class JoinLeagueDatatable < ApplicationDatatable
  delegate :logger, :t, :admin_leagues_path, :admin_league_edit_path, :admin_league_destroy_path, :leagueBadge, :dt_actionsMenu, :join_league_path, :image_tag, :vite_asset_url, :vite_image_tag, :content_tag, :button_to, to: :@view

  private

  def data
    leagues.map do |league|
      lName = vite_image_tag(leagueBadge(league), class: "rounded me-1", height: "28", width: "28")
      lName += league.name

      lStatus = if league.status
        content_tag(:span, t("active"), class: "badge badge-soft-success")
      else
        content_tag(:span, t("inactive"), class: "badge badge-soft-light")
      end

      platform = league.platform

      league_users = League.joins([user_leagues: :user]).where(leagues: { id: league.id }, user_leagues: { status: true }, users: { role: 0 } ).where("(users.preferences -> 'fake')::Boolean = ?", false).count

      slots = (league.slots - league_users)

      join_text = slots > 0 ? t("defaults.datatables.confirm_join_league_text") : t("defaults.datatables.confirm_join_league_text_noslots")

      dtActions = '<div class="d-inline-flex">'
      dtActions += link_to t("request_join"), "javascript:;", method: :post, class: "btn btn-primary", data: {controller: "confirm", "turbo-frame": "navigation", "turbo-action": "replace", action: "click->confirm#dialog", "confirm-title-value": t("defaults.datatables.confirm_join_league", league: league.name), "confirm-text-value": join_text, "confirm-action-value": "post", "confirm-turbo-value": "false", "confirm-icon-value": "question", "confirm-link-value": join_league_path(league_id: league.friendly_id)}
      dtActions += "</div>"

      {
        id: league.id,
        name: lName,
        slots: slots,
        status: lStatus,
        platform: platform,
        users: league_users,
        DT_Actions: dtActions,
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

    leagues = League.eager_load(:user_leagues).where(leagues: {status: true})
    leagues = leagues.page(page).per(per_page)
    leagues = leagues.where(search_string.join(" AND "))
    if sort_column == "users"
      leagues = leagues.order(Arel.sql("count(user_leagues.league_id) #{sort_direction}"))
      leagues = leagues.group("leagues.id, user_leagues.id")
    else
      leagues = leagues.order(Arel.sql("\"#{sort_column}\" #{sort_direction}"))
    end
  end

  def columns
    [
      "name",
      "slots",
      "users"
    ]
  end
end
