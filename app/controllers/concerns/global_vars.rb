module GlobalVars
  extend ActiveSupport::Concern

  included do
    before_action :set_global_vars, :authenticate_user!
  end

  private

    def set_global_vars
      session[:pdbprefix] = Rails.configuration.playerdb_prefix
      if user_signed_in? && current_user.user?
        if !session[:user_id]
          session[:user_id] = current_user.id
          session[:league] = !current_user.preferences["active_league"].blank? ? current_user.preferences["active_league"] : nil
          session[:leagues] = League.joins(:users).where(users: { id: current_user.id } ).pluck('leagues.id')
          session[:season] = Season.getActive(current_user.id)
          if !session[:season].nil?
            session[:userClub] = User.getClub(current_user.id, session[:season]).nil? ? nil : User.getClub(current_user.id, session[:season]).id
          end
          
        end
      elsif user_signed_in? && current_user.manager?
        session[:league] = !current_user.preferences["active_league"].blank? ? current_user.preferences["active_league"] : nil
        session[:leagues] = League.where(user_id: current_user.id).pluck('leagues.id')
        session[:season] = Season.getActive(current_user.id)
      end

      @decodedVapidPublicKey = Base64.urlsafe_decode64(AppConfig.vapid_pubkey).bytes
    end
  
end