class Admin::Insights::InsightsActivitiesController < ApplicationController
  authorize_resource class: false
  breadcrumb "dashboard", :root_path, match: :exact
  breadcrumb "admin.insights.main", :admin_insights_activities_path, match: :exact
  breadcrumb "admin.insights.activities.main", :admin_insights_activities_path, match: :exact

  def index
  end

  def get_proc_dt
    render json: Admin::Insights::ActivitiesDatatable.new(view_context)
  end
end
