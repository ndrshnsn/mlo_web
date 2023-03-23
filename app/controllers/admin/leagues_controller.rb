class Admin::LeaguesController < ApplicationController
  include FakeAccounts
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
  end

  def update
    league = League.friendly.find(params[:id])
    result = AdminServices::UpdateLeague.call(league, league_params)
    respond_to do |format|
      if result.success?
        flash['success'] = t('.success')
        format.html { redirect_to admin_leagues_path }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    league = League.friendly.find(params[:id])

    ## Remove Fake Accounts
    fAccounts = UserLeague.joins(:user).where("user_leagues.league_id = ? AND users.preferences -> 'fake' = ?", league.id, "true").pluck("users.id")
    User.where(id: fAccounts).destroy_all

    respond_to do |format|
      if league.destroy!
        flash.now["success"] = t('.success')
        format.turbo_stream
        format.html { redirect_to admin_leagues_path, notice: t('.success') }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def get_proc_dt
    render json: Admin::LeaguesDatatable.new(view_context)
  end

  def create
    @league = League.new(league_params)
    if @league.save!
      adm = User.find(league_params[:user_id])
      adm.update(
        request: false,
        active_league: @league.id,
        role: "manager",
      )

      ## Create fake accounts
      createFakeAccounts(@league)

      League.sendAdminLeagueWelcome(
        adm.email,
        league_params[:name],
        adm.full_name
      )

      flash["success"] = t('.success')
    else
      flash["error"] = t('.error')
    end
    redirect_to admin_leagues_path
  end


  private

  def set_local_vars
    @managers = User.where(role: "manager")
  end

  def league_params
    params.require(:league).permit(:name, :user_id, :platform, :status, :slots)
  end

end
