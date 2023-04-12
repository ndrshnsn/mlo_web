class Admin::Playerdb::CountriesDatatable < ApplicationDatatable
  delegate :logger, :t, :image_tag, :content_tag, :admin_playerdb_countries_destroy_path, :admin_playerdb_countries_edit_path, :dt_actionsMenu, :button_to, to: :@view

  private

  def data
    playernationalities.map do |playernationality|
      cLogoName = DefCountry.getISO(playernationality.name.humanize)
      cLogo = ""
      if !cLogoName.nil?
        cLogo = image_tag("flags/#{cLogoName}.svg", class: "rounded mr-50", height: "18", width: "24")
      end

      dtActions = [
        {
          link: admin_playerdb_countries_edit_path(playernationality),
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
          turbo: "data-action='click->confirm#dialog' data-controller='confirm' data-confirm-title-value='#{t("defaults.datatables.confirm_remove")}' data-confirm-text-value='#{t("defaults.datatables.confirm_remove_text")}' data-confirm-icon-value='warning' data-confirm-link-value='#{admin_playerdb_countries_destroy_path(playernationality)}'"
        }
      ]

      {
        id: playernationality.id,
        flag: cLogo,
        name: playernationality.name,
        alias: playernationality.alias,
        DT_Actions: dt_actionsMenu(dtActions),
        DT_RowId: playernationality.id
      }
    end
  end

  def count
    DefCountry.count
  end

  def total_entries
    playernationalities.total_count
  end

  def playernationalities
    @playernationalities ||= fetch_playernationalities
  end

  def fetch_playernationalities
    search_string = []
    columns.each_with_index do |term, i|
      if params[:columns]["#{i}"][:searchable] == "true" && params[:search][:value].present?
        search_string << "\"#{term}\" ilike '%#{params[:search][:value]}%'"
      end
    end
    playernationalities = DefCountry.order("\"#{sort_column}\" #{sort_direction}")
    playernationalities = playernationalities.page(page).per(per_page)
    playernationalities = playernationalities.where(search_string.join(" OR "))
  end

  def columns
    [
      "id",
      "name",
      "alias"
    ]
  end
end
