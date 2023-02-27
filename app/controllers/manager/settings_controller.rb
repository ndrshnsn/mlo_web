class Manager::SettingsController < ApplicationController
  authorize_resource class: false
  before_action :set_local_vars
  breadcrumb "dashboard", :root_path, match: :exact
  breadcrumb "manager.settings.main", :manager_settings_path, match: :exact

  def index
  end

  def update
    league = League.friendly.find(params[:id])
    respond_to do |format|
      if league.update(league_params)
        flash.now["success"] = t('.success')
        format.turbo_stream
        format.html { redirect_to manager_settings_path, notice: t('.success') }
      else
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_local_vars
    if current_user.role == "manager"
      @league = League.find(session[:league])
    end
  end

  def league_params
    params.require(:league).permit(
      :name,
      :badge
    )
  end
end