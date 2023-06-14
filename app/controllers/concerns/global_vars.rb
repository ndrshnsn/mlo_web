module GlobalVars
  extend ActiveSupport::Concern

  included do
    before_action :set_global_vars, :authenticate_user!
  end

  private

  def set_global_vars
    session[:error_list] = []
    session[:pdbprefix] = Rails.configuration.playerdb_prefix
    if user_signed_in? && current_user.user?
      if !session[:user_id]
        session[:user_id] = current_user.id
        session[:league] = current_user.preferences["active_league"].presence
        session[:leagues] = League.joins(:users).where(users: {id: current_user.id}).pluck("leagues.id")
        session[:season] = Season.getActive(current_user.id)
        if !session[:season].nil?
          session[:userClub] = User.getClub(current_user.id, session[:season]).nil? ? nil : User.getClub(current_user.id, session[:season]).id
        end
      end
    elsif user_signed_in? && current_user.manager?
      session[:league] = current_user.preferences["active_league"].presence
      session[:leagues] = League.where(user_id: current_user.id).pluck("leagues.id")
      session[:season] = Season.getActive(current_user.id)
    end
    @decoded_vapid_publickey = Base64.urlsafe_decode64(ENV['VAPID_PUBLIC_KEY']).bytes
  end

  def general_error(code, clear = nil)
    session[:error_list] = [] if clear == true
    code.each do |i|
      session[:error_list].push(
        code: i,
        title: I18n.t("error_list.#{i}.title"),
        desc: I18n.t("error_list.#{i}.desc")
      )
    end
  end
end