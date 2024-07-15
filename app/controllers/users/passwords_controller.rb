# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController
  # GET /resource/password/new
  # def new
  #   super
  # end

  # POST /resource/password
  # def create
  #   super
  # end

  # GET /resource/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/password
  def update
    if params[:user].key?(:reset_password_token)
      begin
        @user = User.find_by(reset_password_token: params[:user][:reset_password_token])
        @user.reset_password(params[:user][:password], params[:user][:password_confirmation])
      rescue NoMethodError
        flash[:alert] = "An error occurred, please try again."
        redirect_to new_user_password_path
      else
        flash[:notice] = "Password reset successfully, please sign in with your new password"
        redirect_to new_user_session_path
      end
    else
      @user = User.find_by(email: params[:user][:email])
      @user.send_reset_password_instructions
      flash[:notice] = "Emailed instructions on how to reset password"
      redirect_to new_user_session_path
    end
  end

  protected

  def after_resetting_password_path_for(resource)
    root_path
  end

  # The path used after sending reset password instructions
  def after_sending_reset_password_instructions_path_for(resource_name)
    super(resource_name)
  end
end
