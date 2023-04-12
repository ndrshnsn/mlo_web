# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  def check_email
    status = User.exists?(email: params[:user][:email]) ? :unauthorized : :ok
    render body: nil, status: status
  end

  def check_current_password
    status = current_user.valid_password?(params[:user][:current_password]) ? :ok : :unauthorized
    render body: nil, status: status
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :full_name, :platform, :role, :nickname, :phone, :birth])
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:email, :full_name, :platform, :role, :nickname, :phone, :birth])
  end

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    new_user_session_path
  end

  # The path used after sign up for inactive accounts.
  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end

  def after_update_path_for(resource)
    root_path
  end
end
