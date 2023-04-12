class Admin::AccountsController < ApplicationController
  authorize_resource class: false
  breadcrumb "dashboard", :admin_accounts_path, match: :exact
  breadcrumb "admin.accounts.main", :admin_accounts_path, match: :exact

  def index
  end

  def edit
    @user = User.friendly.find(params[:id])
    @user_active_status =
      if @user.active
        "active"
      else
        @user.confirmed_at.nil? ? "pending" : "inactive"
      end
  end

  def update
    user = User.friendly.find(params[:id])
    active_value = true unless user_params[:status] == "inactive"
    respond_to do |format|
      if user.update!(
        role: Integer(user_params[:role], 10),
        active: active_value
      )

        flash["success"] = t(".success")
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
        flash.now["success"] = t(".success")
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
