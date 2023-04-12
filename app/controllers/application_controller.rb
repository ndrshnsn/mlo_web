class ApplicationController < ActionController::Base
  include Authenticable
  include Authorizable
  include Timeoutable
  include GlobalVars
  include SetLocale
  include SetTheme
  include PublicActivity::StoreController

  ## HTML
  before_action :authenticate_user!, except: [:raise_not_found, :not_found, :error]

  ## Custom Flash Types
  add_flash_types :success, :info, :error, :warning

  # Disable CSRF protection for json calls
  protect_from_forgery with: :exception, prepend: true, unless: :json_request?
  before_action :set_locale, unless: :json_request?
  before_action :set_theme, unless: :json_request?
  layout -> { turbo_frame_request? ? false : layout_by_resource }
  auto_session_timeout 20.minutes

  ## API
  protect_from_forgery with: :null_session, if: :json_request?
  skip_before_action :verify_authenticity_token, if: :json_request?
  rescue_from ActionController::InvalidAuthenticityToken, with: :invalid_auth_token
  before_action :set_current_user, if: :json_request?

  protected

  def json_request?
    request.format.json?
  end

  # So we can use Pundit policies for api_customers
  def set_current_user
    @current_user ||= warden.authenticate(scope: :api_user)
  end
end
