module Authenticable
  extend ActiveSupport::Concern

  included do
    # Use api_customer Devise scope for JSON access
    def authenticate_user!(*args)
      super and return if args.present?
      if request.path.start_with?("/api")
        authenticate_api_user!
        return
      end
      super
    end

    def invalid_auth_token
      respond_to do |format|
        format.html { redirect_to sign_in_path, error: "Login invalid or expired" }
        format.json { head :unauthorized }
      end
    end
  end
end
