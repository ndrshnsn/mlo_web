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

  def create
    @league = League.new(league_params)
    respond_to do |format|
      if @league.save!
        adm = User.find(league_params[:user_id])
        if adm.update!(
          request: false,
          active_league: @league.id,
          role: "manager"
          )

          @league.slots.times do |i|
            create_fake = AppServices::Users::CreateFake.call
            if create_fake.user
              UserLeague.new(
                league_id: @league.id,
                user_id: create_fake.user.id,
                status: true
              ).save!
            end
          end
        end
        AdminMailer.with(league: @league).create_league.deliver_later

        format.html { redirect_to admin_leagues_path, success: t(".success") }
        format.turbo_stream { flash.now["success"] = t(".success") }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def update
    @league = League.friendly.find(params[:id])
    padm = User.find(@league.user_id)
    pslots = @league.slots
    errors = []

    respond_to do |format|
      #if pslots > league_params[:slots].to_i
      if @league.update(league_params)

        adm = User.find(league_params[:user_id])
        if padm.id != adm.id
          if UserLeague.where(user_id: padm.id).count > 1
            padm.preferences["active_league"] = UserLeague.where(user_id: padm.id).where.not(league_id: @league.id).first.id
          else
            padm.update(
              active_league: nil,
              active: false,
              role: "user"
            )
          end

          adm.update!(
            request: false,
            active_league: @league.id,
            role: "manager"
          )
        end

        ## Update Slots
        if pslots != @league.slots

        end

        format.html { redirect_to admin_leagues_path, success: t(".success") }
        format.turbo_stream { flash.now["success"] = t(".success") }
      else
        errors.push(
          {
            code: "error code",
            message: "error test message"
          }
        )

        format.turbo_stream { render turbo_stream: turbo_stream.update("edit_league_form", partial: "form", locals: { league: @league, error_list: errors, url: admin_league_update_path }) }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    league = League.friendly.find(params[:id])

    fake_accounts = UserLeague.joins(:user).where("user_leagues.league_id = ? AND users.preferences -> 'fake' = ?", league.id, "true").pluck("users.id")
    User.where(id: fake_accounts).destroy_all

    respond_to do |format|
      if league.destroy!
        flash.now["success"] = t(".success")
        format.turbo_stream
        format.html { redirect_to admin_leagues_path, notice: t(".success") }
      else
        format.html { render :edit, status: :unprocessable_entity }
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
