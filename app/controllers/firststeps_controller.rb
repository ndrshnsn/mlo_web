class FirststepsController < ApplicationController
  layout "firststeps"

  def index
  end

  def get_proc_dt
    render json: JoinLeagueDatatable.new(view_context)
  end

  def check_lname
    status = League.exists?(name: params[:name]) ? :unauthorized : :ok
    render body: nil, status: status
  end

  def join_league
    @select_account_type = true
    user = User.find(current_user.id)
    league = League.friendly.find(params[:league_id])
    UserLeague.where(
      user_id: user.id,
      league_id: league.id,
      status: false
    ).first_or_create!
    respond_to do |format|
      if user.update!(request: true)
        UserMailer.with(user: user, league: league).join_league.deliver_later
        flash["success"] = t(".success")
        format.html { redirect_to root_path }
      else
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def join
    if current_user.preferences["request"] == true
      redirect_to root_path
    end
    @select_account_type = true
  end

  def request_league
    @select_account_type = true
    if request.post?
      respond_to do |format|
        user = User.find(current_user.id)
        if user.update!(request: true)
          UserMailer.with(user: user, params: league_params).request_league.deliver_later
          flash["success"] = t(".success")
          format.html { redirect_to root_path }
        else
          format.html { render :index, status: :unprocessable_entity }
        end
      end
    end
  end

  private

  def league_params
    params.require(:league).permit(:name, :user_id, :platform, :status, :chatroom_id)
  end
end
