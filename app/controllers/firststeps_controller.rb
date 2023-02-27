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
    @selectAccountType = true
    user = User.find(current_user.id)
    league = League.friendly.find(params[:league_id])
    UserLeague.where(
      user_id: user.id,
      league_id: league.id,
      status: false
    ).first_or_create
    user.update(request: true)
    redirect_to root_path
  end

  def join
    if current_user.preferences["request"] == true
      redirect_to root_path
    end
    @selectAccountType = true
  end

  def requestLeague
    @selectAccountType = true
    if request.post?
      user = User.find(current_user.id)
      lData = league_params
      League.sendRequest(
        user.email,
        lData[:name],
        lData[:platform],
        user.full_name,
        user.email,
        user.phone
      )
      user.update( request: true )
      redirect_to root_path
    end
  end

  private

  def league_params
    params.require(:league).permit(:name, :user_id, :platform, :status, :chatroom_id)
  end
end
