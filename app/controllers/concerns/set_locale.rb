module SetLocale
  extend ActiveSupport::Concern

  private

  def set_locale
    I18n.locale = params[:locale] ||    # Request parameter
      session[:locale] ||               # Current session
      (current_user.preferences["locale"] if user_signed_in? && !current_user.preferences["locale"].blank?) ||  # Model saved configuration
      extract_locale_from_accept_language_header ||          # Language header - browser config
      I18n.default_locale
  end
  
  def extract_locale_from_accept_language_header
    if request.env['HTTP_ACCEPT_LANGUAGE']
      lg = request.env['HTTP_ACCEPT_LANGUAGE'].split(';', 2).first.to_sym
      lg.in?([:'pt-BR', :en, :es]) ? lg : nil
    end
  end


end