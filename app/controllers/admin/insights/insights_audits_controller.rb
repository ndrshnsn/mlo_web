class Admin::Insights::InsightsAuditsController < ApplicationController
  authorize_resource class: false
  breadcrumb "dashboard", :root_path, match: :exact
  breadcrumb "admin.insights.main", :admin_insights_audits_path, match: :exact
  breadcrumb "admin.insights.audits.main", :admin_insights_audits_path, match: :exact

  def index
  end

  def details
    @audit = Audited::Audit.find(params[:id])
  end

  def get_proc_dt
    render json: Admin::Insights::AuditsDatatable.new(view_context)
  end
end
