class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token

  def google_oauth2
    generic_callback('google_oauth2')
  end

  def twitter
    generic_callback('twitter')
  end

  def github
    generic_callback('github')
  end

  def generic_callback(provider)
    if user_signed_in?
      auth = request.env['omniauth.auth']
      data = auth.except('extra') 
      session[:omniauth] = {
        uid: data.uid,
        email: data.info.email,
        full_name: data.info.name,
        gravatar_url: data.info.image,
        provider: data.provider
      }

      if Identity.create_with_omniauth(session[:omniauth], current_user.id)
        flash[:info] = t('pages.register.account_linked')
        redirect_to profile_path(anchor: "profile-social") and return
      end
    end

    auth = request.env['omniauth.auth']
    data = auth.except('extra')
    session[:omniauth] = {
      uid: data['uid'],
      email: data['info']['email'],
      full_name: data['info']['name'],
      gravatar_url: data['info']['image'],
      provider: data['provider']
    }

    @user = User.from_omniauth(auth)
    if @user.persisted?
      if @user.active == false
        redirect_to new_user_session_url, notice: t('users.sessions.new.locked_account')
      else
        @identity = Identity.find_with_omniauth(session[:omniauth])
        @identity = Identity.create_with_omniauth(session[:omniauth], @user.id) if @identity.nil?

        flash[:success] = t('users.sessions.new.signed_in')
        sign_in_and_redirect @user, event: :authentication
      end
    else
      redirect_to register_url
    end
  end

  def action_missing(provider)
  end

  def failure
    redirect_to root_path, notice: t('users.sessions.new.sign_in_error')
  end
end