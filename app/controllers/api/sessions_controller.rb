class Api::SessionsController < Devise::SessionsController
  # I'm guessing this isn't required since we don't track signed in/signed out status for the API user?
  skip_before_action :verify_signed_out_user
  # This sets the default response format to json instead of html
  respond_to :json
  # POST /api/login
  def create
    unless request.format == :json
      sign_out # why is this needed?
      render status: :not_acceptable,
        json: {message: "JSON requests only."} and return
    end
    # auth_options should have `scope: :api_customer`
    resource = warden.authenticate!(auth_options)
    if resource.blank?
      render status: :unauthorized,
        json: {response: "Access denied."} and return
    end
    sign_in(resource_name, resource)
    respond_with resource, location: after_sign_in_path_for(resource) do |format|
      format.json {
        render json: {success: true,
                      jwt: current_token,
                      response: "Authentication successful"}
      }
    end
  end

  private

  def current_token
    request.env["warden-jwt_auth.token"]
  end
end
