class Manager::UsersController < ApplicationController
  include FakeAccounts

  authorize_resource class: false
  before_action :set_local_vars
  breadcrumb "dashboard", :root_path, match: :exact
  breadcrumb "manager.users.main", :manager_users_path, match: :exact

  def index
  end

  def waiting
    render "_waitingUsers"
  end

  def show
    @user = User.friendly.find(params[:id])
    @defCountries = DefCountry.getSorted
  end

  def toggle
    @user = User.friendly.find(params[:id])
    @uLeague = UserLeague.find_by(league_id: @league.id, user_id: @user.id)
    respond_to do |format|
      if @uLeague.status == false
        if fakeSlots(@league) > 0
          if removeFakeAddUser(@user, @league)
              ## SEND EMAIL NOTIFICATION TO USER
              updateTabNumbers
              flash.now["success"] = t('.user_activated')
              format.html { redirect_to manager_users_path, notice: t('.user_activated') }
              format.turbo_stream
          else
            flash.now["danger"] = t('.no_more_slots')
            format.turbo_stream
            format.html { render :index, status: :unprocessable_entity }
          end
        else
          flash.now["warning"] = t('.no_more_slots_remove_some')
          format.turbo_stream
          format.html { render :index, status: :unprocessable_entity }
        end
      else
        if disableUserCreateFake(@user, @league)
          updateTabNumbers
          flash.now["success"] = t('.user_deactivated')
          format.html { redirect_to manager_users_waiting_path, notice: t('.user_deactivated') }
          format.turbo_stream
        else
          flash.now["warning"] = t('.user_deactivated')
          format.html { redirect_to manager_users_waiting_path, notice: t('.user_deactivated') }
        end
      end
    end
  end

  def eseason_enable
    origin = User.friendly.find(params[:id])
    destiny = User.find(params[:user][:choose_user_id])

    respond_to do |format|
      if destiny.preferences["fake"] == true
        if removeFakeAddUser(destiny, origin, @league)
          ## SEND EMAIL NOTIFICATION TO USER
          updateTabNumbers
          flash.now["success"] = t('.user_activated')
          format.html { redirect_to manager_users_path, notice: t('.user_activated') }
          format.turbo_stream
        else
          flash.now["danger"] = t('.error_moving')
          format.turbo_stream
          format.html { render :index, status: :unprocessable_entity }
        end
      else
        if moveUsersBetween(origin, destiny, @league)
          ## SEND EMAIL NOTIFICATION TO USER
          updateTabNumbers
          flash.now["success"] = t('.user_activated')
          format.html { redirect_to manager_users_path, notice: t('.user_activated') }
          format.turbo_stream
        else
          flash.now["danger"] = t('.error_moving')
          format.turbo_stream
          format.html { render :index, status: :unprocessable_entity }
        end
      end
    end
  end

  def eseason
    @user = User.friendly.find(params[:id])
    @users = User.joins(:user_leagues).where(user_leagues: { league_id: session[:league], status: true } )
  end

  def destroy
    user = User.friendly.find(params[:id])
    uLeague = UserLeague.find_by(league_id: @league.id, user_id: user.id)
    leagueCount = UserLeague.where(user_id: user.id).size
    respond_to do |format|
      if removeUserCreateFake(user, @league)
        if leagueCount == 1
          user.preferences["request"] = false
          user.save!
        end
        updateTabNumbers
        flash.now["success"] = t('.user_deactivated')
        format.html { redirect_to manager_users_waiting_path, notice: t('.user_deactivated') }
        format.turbo_stream
      else
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def updateTabNumbers
    @active = UserLeague.where(league_id: @league.id, status: true).size
    @waiting = UserLeague.where(league_id: @league.id, status: false).size
  end

  def get_aproc_dt
    render json: Manager::ActiveUsersDatatable.new(view_context)
  end

  def get_wproc_dt
    render json: Manager::WaitingUsersDatatable.new(view_context)
  end

  private

  def set_local_vars
    if current_user.role == "manager"
      @league = League.find(session[:league])
      updateTabNumbers
    end
  end
end