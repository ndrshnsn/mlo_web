class AppServices::Sendmail < ApplicationService
  def initialize(type, league, params)
    @type = type
    @league = league
    @params = params
  end

  def call
    sendmail
  end

  private

  def sendmail
    case @type
    when 'new_league'
      template = AppConfig.template_new_league_id
    when 'request_league'
      template = AppConfig.template_request_league_id
    end

    @params[:league_name] = nil unless @params[:league_name].present?
    @params[:platform] = nil unless @params[:platform].present?
    @params[:full_name] = nil unless @params[:full_name].present?
    @params[:email] = nil unless @params[:email].present?
    @params[:phone] = nil unless @params[:phone].present?

    data = JSON.parse('{
      "personalizations": [
        {
          "to": [
            {
              "email": "'+AppConfig.mail_admin+'"
            }
          ],
          "dynamic_template_data": {
            "requester_league_name": "'+ @params[:league_name] +'",
            "requester_platform": "'+ @params[:platform] +'",
            "requester_full_name": "'+ @params[:full_name] +'",
            "requester_email": "'+ @params[:email] +'",
            "requester_phone": "'+ @params[:phone] +'"
          }
        }
      ],
      "from": {
        "email": "'+ AppConfig.mail_admin +'"
      },
      "template_id": "'+ template +'"
    }')

    sg = SendGrid::API.new(api_key: AppConfig.sendgrid_api)
    return OpenStruct.new(success?: false, errors: response) unless response = sg.client.mail._("send").post(request_body: data)
    puts response.status_code
    puts response.body
    puts response.headersw

    OpenStruct.new(success?: true, errors: nil)
  end
end