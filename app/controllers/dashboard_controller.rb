class DashboardController < ApplicationController
  before_action :set_controller_vars
  before_action :firstSteps

  def set_controller_vars
    if session[:season]
        if session[:userClub]
          @userClub = Club.find(session[:userClub])
        end
        @season = Season.find(session[:season])
    end

    if session[:league]
      if League.exists?(id: session[:league])
        @league = League.find(session[:league])
        logger.info "---------------"
      else
        ## Set league session to nil and request to true
        uLeague = UserLeague.where(user_id: current_user.id)
        if uLeague.size > 0
          current_user.preferences = {
            active_league: uLeague.first.league_id
          }
          current_user.save!
          session[:league] = uLeague.first.league_id
          @league = League.find(session[:league])
        else 
          current_user.preferences = {
            active_league: "",
            request: false
          }
          current_user.save!
          redirect_to firststeps_path
        end
      end
    end
  end

  def index
  end

  def change_league
    @league = League.friendly.find(params[:id])
    user = User.find(current_user.id)
    respond_to do |format|
      if session[:leagues].include? @league.id
        user.active_league = @league.id
        if user.save!
          current_user = user.reload
          if current_user.role == "user"
            session[:league] = !current_user.preferences["active_league"].blank? ? current_user.preferences["active_league"] : nil
            session[:leagues] = League.joins(:users).where(users: { id: current_user.id } ).pluck('leagues.id')
          elsif current_user.role == "manager"
            session[:league] = !current_user.preferences["active_league"].blank? ? current_user.preferences["active_league"] : nil
            session[:leagues] = League.where(user_id: current_user.id).pluck('leagues.id')
          end
          flash.now["success"] = t('.success')
        else
          flash.now["error"] = t('.error')
        end

        @notifications = Notification.where("recipient_id = ? AND notifications.params -> 'league' = ?", current_user, "#{session[:league]}").order(created_at: :desc).limit(10)
        @unreadNotifications = @notifications.unread.size
        if @unreadNotifications >= 99
          @unreadNotifications = "99+"
        end

        format.turbo_stream
        format.html { redirect_to root_path, status: 303, notice: t('.success') }
      else
        format.html { redirect_to root_path, error: t('.error') }
      end
    end
  end

  def firstSteps
    firstSteps = current_user.role == "user" && current_user.leagues.size == 0 ? true : false
    #@approvedUser = UserLeague.where(user_id: current_user.id).pluck(:status)[0]

    if firstSteps
      redirect_to firststeps_path
    end
  end

end
