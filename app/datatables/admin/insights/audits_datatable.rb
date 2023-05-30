class Admin::Insights::AuditsDatatable < ApplicationDatatable
  delegate :logger, :t, :image_tag, :content_tag, :admin_insights_audit_detail_path, :button_to, to: :@view

  private

  def data
    audits.map do |audit|
      audit_details_button = "
        <a href='" + admin_insights_audit_detail_path(audit) + "' data-turbo-frame='modal'>
          <button type='button' class='btn btn-sm btn-light'>
            <i class='ri ri-information-fill align-bottom'></i>
          </button>
        </a>
      "
      audit_owner = audit.user.email if !audit.user.nil?

      {
        created: I18n.localize(audit.created_at, format: t('date.formats.datetime')),
        version: audit.version,
        type: audit.auditable_type,
        type_id: audit.auditable_id,
        owner: audit_owner,
        action: audit.action,
        DT_Actions: audit_details_button,
        DT_RowId: audit.id
      }
    end
  end

  def count
    audits.size
  end

  def total_entries
    audits.total_count
  end

  def audits
    @audits ||= fetch_audits
  end

  def fetch_audits
    search_string = []
    columns.each_with_index do |term, i|
      if params[:columns]["#{i}"][:searchable] == "true" && params[:search][:value].present?
        search_string << "\"#{term}\" ilike '%#{params[:search][:value]}%'"
      end
    end
    audits = Audited::Audit.all
    audits = audits.page(page).per(per_page)
    audits = audits.where(search_string.join(" OR "))
    audits = audits.order("\"#{sort_column}\" #{sort_direction}")
  end

  def columns
    [
      "created_at",
      "version",
      "auditable_type",
      "user_id",
      "action"
    ]
  end
end
