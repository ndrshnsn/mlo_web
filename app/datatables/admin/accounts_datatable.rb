class Admin::AccountsDatatable < ApplicationDatatable
  delegate :logger, :t, :admin_accounts_path, :admin_account_destroy_path, :admin_account_toggle_path, :admin_account_edit_path, :image_tag, :dt_actionsMenu, :avatarURL, :content_tag, :button_to, to: :@view

  private

  def data
    accounts.map do |account|
      stColumn = "<div class='d-flex align-items-center'>"
      stColumn += "<div class='flex-shrink-0'>"
      stColumn += link_to admin_accounts_path do
        content_tag(:img, "", src: avatarURL(account), class: "avatar-sm rounded-circle", style: "width: 32px; height: 32px;")
      end
      stColumn += "</div>"
      stColumn += "<div class='flex-grow-1 ms-2'>"
      stColumn += link_to account.full_name, admin_accounts_path, class: "font-weight-bold d-block text-nowrap"
      stColumn += "<small class='text-muted'>##{account.nickname}</small>"
      stColumn += "</div>"
      stColumn += "</div>"

      if account.admin?
        aRole = content_tag(:span, t("role.admin").upcase, class: "badge badge-soft-warning text-capitalize")
      elsif account.user?
        aRole = content_tag(:span, t("role.user").upcase, class: "badge badge-soft-secondary")
      elsif account.manager?
        aRole = content_tag(:span, t("role.manager").upcase, class: "badge badge-soft-success")
      end

      aStatus = if account.active
        content_tag(:span, t("active").upcase, class: "badge badge-soft-success")
      elsif account.confirmed_at.nil?
        content_tag(:span, t("pending").upcase, class: "badge badge-soft-warning")
      else
        content_tag(:span, t("inactive").upcase, class: "badge badge-soft-light")
      end

      pStatus = (account.active == true) ? t("defaults.datatables.disable") : t("defaults.datatables.enable")
      pStatusIcon = (account.active == true) ? "close" : "check"
      pStatusConfirm = (account.active == true) ? t("defaults.datatables.confirm_disable") : t("defaults.datatables.confirm_enable")

      dtActions = [
        {
          link: admin_account_edit_path(account.friendly_id),
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
          turbo: "data-action='click->confirm#dialog' data-controller='confirm' data-confirm-title-value='#{t("defaults.datatables.confirm_remove")}' data-confirm-text-value='#{t("defaults.datatables.confirm_remove_text")}' data-confirm-icon-value='warning' data-confirm-link-value='#{admin_account_destroy_path(account.friendly_id)}'"
        }
      ]

      {
        id: account.id,
        avatar: stColumn,
        email: account.email,
        role: aRole,
        status: aStatus,
        DT_Actions: dt_actionsMenu(dtActions),
        DT_RowId: account.id
      }
    end
  end

  def count
    User.count
  end

  def total_entries
    accounts.total_count
  end

  def accounts
    @accounts ||= fetch_accounts
  end

  def fetch_accounts
    search_string = []
    columns.each_with_index do |term, i|
      if params[:columns]["#{i}"][:searchable] == "true" && params[:columns]["#{i}"][:search][:value].present?
        if term == "role"
          search_string << Arel.sql("\"#{term}\" = #{params[:columns]["#{i}"][:search][:value]}")
        elsif term == "active"
          if params[:columns]["#{i}"][:search][:value] == "active"
            search_string << "active = true"
          elsif params[:columns]["#{i}"][:search][:value] == "inactive"
            search_string << "active = false"
          elsif params[:columns]["#{i}"][:search][:value] == "pending"
            search_string << "confirmed_at IS NULL"
          end
        else
          search_string << Arel.sql("\"#{term}\" ilike '%#{params[:columns]["#{i}"][:search][:value]}%'")
        end
      end
    end

    accounts = User.order(Arel.sql("\"#{sort_column}\" #{sort_direction}"))
    accounts = accounts.page(page).per(per_page)
    accounts = accounts.where(search_string.join(" AND "))
    accounts = accounts.where("(preferences -> 'fake')::boolean = false")
  end

  def columns
    [
      "full_name",
      "email",
      "role",
      "active"
    ]
  end
end
