class Admin::LeaguesController < ApplicationController
  authorize_resource class: false
  before_action :set_local_vars
  breadcrumb "dashboard", :admin_accounts_path, match: :exact
  breadcrumb "admin.leagues.main", :admin_leagues_path, match: :exact

  def index
  end

  def new
    @league = League.new
  end

  def edit
    @league = League.friendly.find(params[:id])
    @running_season = @league.seasons.where(status: 1).size == 1 ? true : false
  end

  def create
    new_league = AdminServices::CreateLeague.call(league_params: league_params)
    respond_to do |format|
      if new_league.success?
        format.html { redirect_to admin_leagues_path, success: t(".success") }
        format.turbo_stream { flash.now["success"] = t(".success") }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def update
    @league = League.friendly.find(params[:id])
    update_league = AdminServices::UpdateLeague.call(@league, league_params)
    respond_to do |format|
      if update_league.success?
        format.html { redirect_to admin_leagues_path, success: t(".success") }
        format.turbo_stream { flash.now["success"] = t(".success") }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.update("edit_league_form", partial: "form", locals: { league: @league, url: admin_league_update_path }) }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    league = League.friendly.find(params[:id])
    fake_accounts = UserLeague.get_fake_accounts(league.id)
    User.where(id: fake_accounts.pluck("users.id")).destroy_all
    respond_to do |format|
      if league.destroy!
        flash.now["success"] = t(".success")
        format.turbo_stream
        format.html { redirect_to admin_leagues_path, notice: t(".success") }
      else
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def get_proc_dt
    render json: Admin::LeaguesDatatable.new(view_context)
  end

  private

  def set_local_vars
    @managers = User.where(role: "manager")
  end

  def league_params
    params.require(:league).permit(:name, :user_id, :platform, :status, :slots)
  end
end
