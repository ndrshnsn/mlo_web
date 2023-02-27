class Manager::AwardsDatatable < ApplicationDatatable
  delegate :logger, :t, :image_tag, :content_tag, :manager_award_destroy_path, :manager_award_edit_path, :manager_award_destroy_path, :dt_actionsMenu, :awardTrophy, :toCurrency, :button_to, :session, to: :@view

  private

  def data
    awards.map do |award|
      aName = "<div class='d-flex align-items-center'>"
      aName += "<div class='flex-shrink-0'>"
      aName += link_to "#" do
        content_tag(:img, "", src: awardTrophy(award), class: "avatar-sm rounded-circle", style: "width: 32px; height: 32px;")
      end
      aName += "</div>"
      aName += "<div class='flex-grow-1 ms-2'>"
      aName += link_to award.name, "#", class: "font-weight-bold d-block text-nowrap"
      aName += "</div>"
      aName += "</div>"

      if award.status
        aStatus = content_tag(:span, t('active').upcase, class: 'badge badge-soft-success')
      else
        aStatus = content_tag(:span, t('inactive').upcase, class: 'badge badge-soft-light')
      end

      dtActions = [
        {
          link: manager_award_edit_path(award.hashid),
          icon: "ri-edit-line",
          text: t('defaults.datatables.edit'),
          disabled: "",
          turbo: "data-turbo-action='advance'"
        },
        {
          link: "javascript:;",
          icon: "ri-delete-bin-fill",
          text: t('defaults.datatables.delete'),
          disabled: "",
          turbo: "data-action='click->confirm#dialog' data-controller='confirm' data-confirm-title-value='#{t('defaults.datatables.confirm_remove')}' data-confirm-text-value='#{t('defaults.datatables.confirm_remove_text')}' data-confirm-icon-value='warning' data-confirm-link-value='#{manager_award_destroy_path(award.hashid)}'"
        }
      ]

      {
        id: award.id,
        name: aName,
        prize: award.prize,
        prizeValue: toCurrency(award.prize),
        ranking: award.ranking,
        status: aStatus,
        DT_Actions: dt_actionsMenu(dtActions),
        DT_RowId: award.id
      }
    end
  end

  def count
    Award.count
  end

  def total_entries
    awards.total_count
  end

  def awards
    @awards ||= fetch_awards
  end

  def fetch_awards
    search_string = []
    columns.each_with_index do |term, i|
      if params[:columns]["#{i}"][:searchable] == "true" && !params[:search][:value].blank?
          search_string << "\"#{term}\" ilike '%#{params[:search][:value]}%'"
      end
    end
    awards = Award.order("\"#{sort_column}\" #{sort_direction}").where(awards: { league_id: session[:league] })
    awards = awards.page(page).per(per_page)
    awards = awards.where(search_string.join(' OR '))
  end

  def columns
    [
      'name',
      'prize',
      'ranking',
      'status'
    ]
  end
end
