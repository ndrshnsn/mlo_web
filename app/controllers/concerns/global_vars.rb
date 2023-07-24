module GlobalVars
  extend ActiveSupport::Concern

  included do
    before_action :set_global_vars, if: :user_signed_in?
    before_action :check_global_notify, if: :user_signed_in?
  end

  private

  def set_global_vars
    session[:error_list] = []
    session[:pdbprefix] = Rails.configuration.playerdb_prefix
    if current_user.user?
      if !session[:user_id]
        session[:user_id] = current_user.id
        session[:league] = current_user.preferences["active_league"].presence
        session[:leagues] = League.joins(:users).where(users: {id: current_user.id}).pluck("leagues.id")
        session[:season] = Season.getActive(current_user.id)
        session[:userClub] = User.getClub(current_user.id, session[:season]).nil? ? nil : User.getClub(current_user.id, session[:season]).id if !session[:season].nil?
      end
    end

    if current_user.manager?
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

  def check_global_notify
    if current_user.user? && session[:season]
      season = Season.find(session[:season])
      if season.preferences["saction_clubs_choosing"] == 1
        @global_notify = "test"
      end
    end
  end
end