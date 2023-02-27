# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  before_action :configure_sign_in_params, only: [:create]
  skip_before_action :verify_authenticity_token, only: [:create]
  respond_to :html
  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message!(:success, :signed_in)
    sign_in(resource_name, resource)
    yield resource if block_given?
    respond_with resource, location: after_sign_in_path_for(resource)
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end
  def destroy
    super do
      # Turbo requires redirects be :see_other (303); so override Devise default (302)
      return redirect_to after_sign_out_path_for(resource_name), status: :see_other
    end
  end

  # #configure auto_session_timeout
  def active
    render_session_status
  end

  def timeout
    flash.now[:danger] = "Sua sessão expirou, faça login novamente."
    redirect_to new_user_session_path
  end

  def after_sign_in_path_for(resource)
    if resource.sign_in_count == 1
      profile_path
    else
      root_path
    end
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:email, :password])
  end
end
