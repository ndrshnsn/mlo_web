class League < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged
  include BadgeUploader::Attachment(:badge)

  has_many :user_leagues, dependent: :destroy
  has_many :users, through: :user_leagues
  has_many :seasons, dependent: :destroy
  has_many :awards, dependent: :destroy

  def self.sendRequest(to,league_name, platform, full_name, email, phone)
    data = JSON.parse('{
      "personalizations": [
        {
          "to": [
            {
              "email": "'+AppConfig.mail_admin+'"
            }
          ],
          "dynamic_template_data": {
            "requester_league_name": "'+league_name+'",
            "requester_platform": "'+platform+'",
            "requester_full_name": "'+full_name+'",
            "requester_email": "'+email+'",
            "requester_phone": "'+phone+'"
          }
        }
      ],
      "from": {
        "email": "'+AppConfig.mail_admin+'"
      },
      "template_id": "'+AppConfig.template_request_league_id+'"
    }')

    sg = SendGrid::API.new(api_key: AppConfig.sendgrid_api)
    response = sg.client.mail._("send").post(request_body: data)
    puts response.status_code
    puts response.body
    puts response.headers
  end

  ##
  # Send mail to new Admin League about new league created
  def self.sendAdminLeagueWelcome(to,league_name, full_name)
    data = JSON.parse('{
      "personalizations": [
        {
          "to": [
            {
              "email": "'+to+'"
            }
          ],
          "dynamic_template_data": {
            "recipient_full_name": "'+full_name+'",
            "recipient_league_name": "'+league_name+'"
          }
        }
      ],
      "from": {
        "email": "'+AppConfig.mail_admin+'"
      },
      "template_id": "'+AppConfig.template_new_league_id+'"
    }')

    sg = SendGrid::API.new(api_key: AppConfig.sendgrid_api)
    response = sg.client.mail._("send").post(request_body: data)
    puts response.status_code
    puts response.body
    puts response.headers
  end
end
