module Authorizable
  extend ActiveSupport::Concern

  included do
    rescue_from CanCan::AccessDenied do |exception|
      flash.now[:danger] = t("unauthorized")
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream:
            [
              turbo_stream.update("dashboard", partial: "dashboard/main"),
              turbo_stream.update("flash", partial: "layouts/flash/main")
            ]
        end
        format.html { redirect_to root_path, error: t("unauthorized") }
      end
    end
  end

  private

  def current_ability
    controller_name_segments = params[:controller].split("/")
    controller_name_segments.pop
    controller_namespace = controller_name_segments.join("/").camelize
    Ability.new(current_user, controller_namespace)
  end
end
