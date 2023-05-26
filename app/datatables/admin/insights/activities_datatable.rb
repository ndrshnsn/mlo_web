class Admin::Insights::ActivitiesDatatable < ApplicationDatatable
  delegate :logger, :t, :image_tag, :content_tag, :button_to, to: :@view

  private

  def data
    activities.map do |activity|
      activity_created = I18n.localize(activity.created_at, format: t('date.formats.default'))
      activity_element = activity.trackable.id if !activity.trackable.nil?
      activity_owner = activity.owner.full_name if !activity.owner.nil?
      {
        id: activity.id,
        created: activity_created,
        type: activity.trackable_type,
        element: activity_element,
        action: activity.key,
        owner: activity_owner,
        params: activity.parameters.inspect,
        DT_RowId: activity.id
      }
    end
  end

  def count
    PublicActivity::Activity.count
  end

  def total_entries
    activities.total_count
  end

  def activities
    @activities ||= fetch_activities
  end

  def fetch_activities
    search_string = []
    columns.each_with_index do |term, i|
      if params[:columns]["#{i}"][:searchable] == "true" && params[:search][:value].present?
        search_string << "\"#{term}\" ilike '%#{params[:search][:value]}%'"
      end
    end
    activities = PublicActivity::Activity.order("\"#{sort_column}\" #{sort_direction}")
    activities = activities.page(page).per(per_page)
    activities = activities.where(search_string.join(" OR "))
  end

  def columns
    [
      "created_at",
      "trackable_type",
      "trackable'.'name",
      "key",
      "owner'.'full_name",
      "parameters"
    ]
  end
end
