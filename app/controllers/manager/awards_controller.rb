class Manager::AwardsController < ApplicationController
  authorize_resource class: false
  before_action :set_local_vars
  breadcrumb "dashboard", :root_path, match: :exact, turbo: "false"
  breadcrumb "manager.awards.main", :manager_awards_path, match: :exact, frame: "manager_awards"

  def index
  end

  def new
    @award = Award.new
  end

  def edit
    @award = Award.find(params[:id])
  end

  def create
    award = Award.new(
      name: award_params[:name],
      trophy: award_params[:trophy],
      prize: award_params[:prize],
      ranking: award_params[:ranking],
      status: award_params[:status],
      league_id: @league.id
    )
    respond_to do |format|
      if award.save!
        format.html { redirect_to manager_awards_path, notice: t(".success") }
        format.turbo_stream { flash.now["success"] = t(".success") }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    award = Award.find(params[:id])
    aCount = 0
    AppServices::Award.new().list_awards.each do |award_list|
      aCount += Season.where("league_id = ? AND seasons.preferences ->> 'award_#{award_list[:position]}' = ?", @league.id, award.id).size
    end
    respond_to do |format|
      if aCount == 0
        if award.destroy!
          format.html { redirect_to manager_awards_path, notice: t(".success") }
          format.turbo_stream { flash.now["success"] = t(".success") }
        else
          format.html { render :index, status: :unprocessable_entity }
        end
      else
        format.turbo_stream {flash.now["error"] = t(".error_have_dependencies")}
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def update
    award = Award.find(params[:id])
    respond_to do |format|
      if award.update!(award_params)
        format.turbo_stream { flash.now["success"] = t(".success") }
        format.html { redirect_to manager_awards_path, notice: t(".success") }
      else
        flash.now["success"] = t(".success")
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def get_proc_dt
    render json: Manager::AwardsDatatable.new(view_context)
  end

  private

  def set_local_vars
    if current_user.role == "manager"
      @league = League.find(session[:league])
    end
  end

  def award_params
    params.require(:award).permit(
      :name,
      :trophy,
      :prize,
      :ranking,
      :status
    )
  end
end
