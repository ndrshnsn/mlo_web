class Manager::UsersController < ApplicationController
  authorize_resource class: false
  before_action :set_local_vars
  before_action :set_user, only: [:show, :acl, :acl_save, :toggle, :eseason]
  breadcrumb "dashboard", :root_path, match: :exact, turbo: "false"
  breadcrumb "manager.users.main", :manager_users_path, match: :exact, frame: "manager_users"

  def index
  end

  def waiting
    render "_waitingUsers"
  end

  def set_user
    @user = User.friendly.find(params[:id])
  end

  def show
    breadcrumb @user.friendly_id, manager_user_show_path(@user.friendly_id), match: :exact
    @defCountries = DefCountry.getSorted
  end

  def acl
    @user_acl = UserAcl.where(user_id: @user.id)
    @acls = AppServices::Users::Acl.new().list_acls
    render "_acl"
  end

  def acl_save
    save_acl = AppServices::Users::Acl.new(params: acl_params, user: @user.id, league: params[:league]).save_acls
    respond_to do |format|
      if save_acl.success?
        format.html { redirect_to manager_user_show_path(@user), success: t(".success") }
        format.turbo_stream { flash.now["success"] = t(".success") }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def toggle
    user_league = UserLeague.find_by(league_id: @league.id, user_id: @user.id)
    respond_to do |format|
      if replace_user_with_fake(@user, @league)
        update_tab_numbers
        flash.now["success"] = t(".user_deactivated")
        format.html { redirect_to manager_users_waiting_path, notice: t(".user_deactivated") }
        format.turbo_stream
      end
    end
  end

  def render_index_with_unprocessable_entity
    format.turbo_stream
    format.html { render :index, status: :unprocessable_entity }
  end

  def replace_fake_with_user(fake, user, league)
    previous_user_league = UserLeague.find_by(league_id: league.id, user_id: user.id)
    UserLeague.where(league_id: league.id, user_id: fake.id).update_all(user_id: user.id, status: true)
    UserSeason.where(user_id: fake.id).update_all(user_id: user.id)
    Notification.where(recipient_id: fake.id).update_all(recipient_id: user.id)
    user.preferences["request"] = false
    user.preferences["active_league"] = league.id
    if user.save! && fake.destroy! && previous_user_league.destroy!
      return true
    end
    false
  end

  def replace_user_with_fake(user, league)
    user_league = UserLeague.find_by(league_id: league.id, user_id: user.id)
    new_fake_account = AppServices::Users::CreateFake.call(league.id)
    if new_fake_account.success?
      UserLeague.new(
        league_id: league.id,
        user_id: user.id,
        status: false
      ).save!
      UserSeason.where(user_id: user.id).update_all(user_id: new_fake_account.user.id)
      Notification.where(recipient_id: user.id).update_all(recipient_id: new_fake_account.user.id)
      UserAcl.where(user_id: user.id, league_id: league.id).delete_all
      if user_league.update(user_id: new_fake_account.user.id)
        # Check for any other league that user is member
        if UserLeague.where(user_id: user.id).count > 1
          user.preferences["active_league"] = UserLeague.where(user_id: user.id).where.not(league_id: league.id).first.id
        else
          user.preferences["active_league"] = nil
        end
        user.save!
        return true
      else
        return false
      end
    end
    return false
  end

  def move_users_between(origin, destiny, league)
    destiny_user_league = UserLeague.find_by(league_id: league.id, user_id: destiny.id)
    origin_user_league = UserLeague.find_by(league_id: league.id, user_id: origin.id)

    destiny_user_league.update(
      user_id: origin.id,
      status: true
      )

    origin_user_league.update(
      user_id: destiny.id,
      status: false
      )

    prev_user_leagues = League.joins([seasons: :user_seasons]).where(leagues: { id: league.id }, user_seasons: { user_id: destiny.id }).pluck("seasons.id")
    UserSeason.where(user_id: destiny.id, season_id: prev_user_leagues).update_all(user_id: origin.id)
    UserAcl.where(user_id: destiny.id, league_id: league.id).update_all(user_id: origin.id)

    origin.preferences["request"] = false
    if origin.save
      return true
    else
      return false
    end
  end

  def eseason_enable
    origin = User.friendly.find(params[:id])
    destiny = User.find(params[:user][:choose_user_id])

    respond_to do |format|
      if destiny.preferences["fake"] == true
        if replace_fake_with_user(destiny, origin, @league)
          UserMailer.with(user: origin, league: @league).added_to_league.deliver_later
          update_tab_numbers
          flash.now["success"] = t(".user_activated")
          format.html { redirect_to manager_users_path, notice: t(".user_activated") }
          format.turbo_stream
        else
          flash.now["danger"] = t(".error_moving")
          render_index_with_unprocessable_entity
        end
      elsif move_users_between(origin, destiny, @league)
        UserMailer.with(user: origin, league: @league).added_to_league.deliver_later
        UserMailer.with(user: destiny, league: @league).made_inactive_in_league.deliver_later
        update_tab_numbers
        flash.now["success"] = t(".user_activated")
        format.html { redirect_to manager_users_path, notice: t(".user_activated") }
        format.turbo_stream
      else
        flash.now["danger"] = t(".error_moving")
        render_index_with_unprocessable_entity
      end
    end
  end

  def eseason
    @users = User.joins(:user_leagues).where(user_leagues: {league_id: session[:league], status: true})
  end

  def destroy
    user = User.friendly.find(params[:id])
    user_leagues = user.user_leagues
    user_league_size = user_leagues.size

    respond_to do |format|
      user_league = UserLeague.find_by(league_id: @league.id, user_id: user.id)
      if user_league.destroy!
        if user_league_size == 1
          user.preferences["request"] = false
          user.preferences["active_league"] = nil
        else
          random_league = user_leagues.where.not(league_id: @league.id).order(Arel.sql("RANDOM()")).limit(1).first
          user.preferences["active_league"] = random_league&.id
        end

        if user.save!
          UserMailer.with(user: user, league: @league).removed_from_league.deliver_later
          update_tab_numbers
          format.html { redirect_to manager_users_waiting_path, notice: t(".user_removed") }
          format.turbo_stream { flash.now["success"] = t(".user_removed") }
        else
          format.html { render :index, status: :unprocessable_entity }
        end
      else
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def update_tab_numbers
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

  def acl_params
    params.require(:acl_rule).permit!
  end

  def set_local_vars
    @league = League.find(session[:league])
    update_tab_numbers
  end
end
