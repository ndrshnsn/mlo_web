# frozen_string_literal: true

class Admin::AccountsController < ApplicationController
  authorize_resource class: false
  breadcrumb "dashboard", :admin_accounts_path, match: :exact
  breadcrumb "admin.accounts.main", :admin_accounts_path, match: :exact

  def index; end

  def edit
    @user = User.friendly.find(params[:id])
    if @user.active
      @userActiveStatus = 'active'
    else
      if @user.confirmed_at.nil?
        @userActiveStatus = 'pending'
      else
        @userActiveStatus = 'inactive'
      end
    end
  end

  def update
    user = User.friendly.find(params[:id])
    result = AdminServices::UpdateAccount.call(user, user_params)
    respond_to do |format|
      if result.success?
        flash["success"] = t('.success')
        format.html { redirect_to admin_accounts_path }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    user = User.friendly.find(params[:id])
    respond_to do |format|
      if user.destroy!
        flash.now["success"] = t('.success')
        format.html { redirect_to admin_accounts_path }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def get_proc_dt
    render json: Admin::AccountsDatatable.new(view_context)
  end

  private

  def user_params
    params.require(:user).permit(
      :role,
      :status
    )
  end
end
