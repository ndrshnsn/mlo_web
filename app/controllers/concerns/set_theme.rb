module SetTheme
  extend ActiveSupport::Concern

  private

  def layout_by_resource
    if devise_controller?
      "basic"
    else
      "application"
    end
  end

  def set_theme
    session[:theme] = (current_user.preferences["theme"] if user_signed_in? && current_user.preferences["theme"].present?) ||
      "dark"
  end
end
