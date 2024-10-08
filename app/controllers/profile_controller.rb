class ProfileController < ApplicationController
  def index
    @user = User.find(current_user.id)
    @defCountries = DefCountry.getSorted
  end

  def user_popover
    @user = User.friendly.find(params[:id])
    render "layouts/user_popover"
  end

  def pw
    @user = User.find(current_user.id)
    render "_pw"
  end

  def system
    @user = User.find(current_user.id)
    @defCountries = DefCountry.getSorted
    @system_notified = @user.web_push_devices.where(user_id: current_user, user_agent: request.user_agent, user_ip: request.ip)
    render "_system"
  end

  def social
    @user = User.find(current_user.id)
    @identities = Identity.where(user_id: @user.id)
    render "_social"
  end

  def social_disconnect
    sIdentity = Identity.find_by(user_id: current_user.id, provider: params[:provider])
    if sIdentity.destroy!
      flash.now["success"] = t(".success")
    else
      flash.now["error"] = t(".error")
    end
    @identities = Identity.where(user_id: @user.id).to_a
    respond_to do |format|
      format.turbo_stream
    end
  end

  def subscribe
    sparams = params
    sub = current_user.web_push_devices.where(user_agent: request.user_agent, user_ip: request.ip)
    if sub.empty?
      WebPushDevice.new(
        user: current_user,
        endpoint: sparams[:subscription][:endpoint],
        auth_key: sparams[:subscription][:keys][:auth],
        p256dh_key: sparams[:subscription][:keys][:p256dh],
        user_agent: request.user_agent,
        user_ip: request.ip
      ).save!
    else
      sub.update(
        endpoint: sparams[:subscription][:endpoint],
        auth_key: sparams[:subscription][:keys][:auth],
        p256dh_key: sparams[:subscription][:keys][:p256dh]
      )
    end
    
    if sub
      flash.now["success"] = t(".success")
    else
      flash.now["error"] = t(".error")
    end
    respond_to do |format|
      format.turbo_stream
    end
  end

  def unsubscribe
    if WebPushDevice.where(user: current_user, user_agent: request.user_agent, user_ip: request.ip).delete_all
      flash.now["success"] = t(".success")
    else
      flash.now["error"] = t(".error")
    end
    respond_to do |format|
      format.turbo_stream
    end
  end

  def update
    @defCountries = DefCountry.getSorted
    @user = User.friendly.find(params[:id])
    respond_to do |format|
      @user.avatar = user_params[:avatar]
      @user.full_name = user_params[:full_name]
      @user.platform = user_params[:platform]
      @user.nickname = user_params[:nickname]
      @user.phone = user_params[:phone]
      @user.birth = user_params[:birth]
      @user.preferences["country"] = user_params[:country]
      @user.preferences["city"] = user_params[:city]
      @user.preferences["twitter"] = user_params[:twitter]
      @user.preferences["facebook"] = user_params[:facebook]
      @user.preferences["instagram"] = user_params[:instagram]
      if @user.save!
        flash.now["success"] = t(".success")
        format.html { redirect_to profile_path, notice: t(".success") }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def update_system
    @user = User.friendly.find(params[:id])
    @user.preferences["locale"] = system_params[:locale]
    @user.preferences["theme"] = system_params[:theme]
    session[:theme] = system_params[:theme]
    if @user.save!
      flash.now["success"] = t(".success")
      redirect_to profile_path, notice: t(".success")
    else
      format.html { render :edit, status: :unprocessable_entity }
    end
  end

  def update_pw
    @user = User.friendly.find(params[:id])
    if @user.update(pwd_params)
      flash.now["success"] = t(".success")
      redirect_to root_path
    else
      format.html { render :edit, status: :unprocessable_entity }
    end
  end

  private

  ## User Params
  def user_params
    params.require(:user).permit(:full_name, :avatar, :platform, :country, :city, :nickname, :phone, :birth, :twitter, :facebook, :instagram)
  end

  ## PWD Params
  def pwd_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def system_params
    params.require(:user).permit(:locale, :theme)
  end
end
