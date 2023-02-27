class CustomDeviseMailer < Devise::Mailer
  layout 'mailer'
  include Devise::Controllers::UrlHelpers
  include SendGrid

  # To make sure that your mailer uses the devise views
  default template_path: 'devise/mailer' 

  def confirmation_instructions(record, token, options={})
    data = JSON.parse('{
      "personalizations": [
        {
          "to": [
            {
              "email": "'+record.email+'"
            }
          ],
          "dynamic_template_data": {
            "recipient_name": "'+record.full_name+'",
            "link": "'+Rails.configuration.root_url+'/confirmation?confirmation_token='+record.confirmation_token+'",
            "subject": "'+I18n.t('mailers.confirmation.subject')+'",
            "subscription_title": "'+I18n.t('mailers.confirmation.subscription_title')+'",
            "main_message": "'+I18n.t('mailers.confirmation.main_message')+'",
            "subscribe_button": "'+I18n.t('mailers.confirmation.subscribe_button')+'",
            "mistake": "'+I18n.t('mailers.confirmation.mistake')+'",
            "developed_by": "'+I18n.t('mailers.confirmation.developed_by')+'"
          }
        }
      ],
      "from": {
        "email": "'+AppConfig.mail_admin+'"
      },
      "template_id": "'+AppConfig.template_confirmation_id+'"
    }')

    sg = SendGrid::API.new(api_key: AppConfig.sendgrid_api)
    response = sg.client.mail._("send").post(request_body: data)
    puts response.status_code
    puts response.body
    puts response.headers
  end

  def reset_password_instructions(record, token, options={})
    data = JSON.parse('{
      "personalizations": [
        {
          "to": [
            {
              "email": "'+record.email+'"
            }
          ],
          "dynamic_template_data": {
            "recipient_name": "'+record.full_name+'",
            "link": "'+Rails.configuration.root_url+'/password/edit?reset_password_token='+record.reset_password_token+'",
            "subject": "'+I18n.t('mailers.reset_password.subject')+'",
            "reset_password_title": "'+I18n.t('mailers.reset_password.reset_password_title')+'",
            "main_message": "'+I18n.t('mailers.reset_password.main_message')+'",
            "reset_password_button": "'+I18n.t('mailers.reset_password.reset_password_button')+'",
            "developed_by": "'+I18n.t('mailers.confirmation.developed_by')+'"
          }
        }
      ],
      "from": {
        "email": "'+AppConfig.mail_admin+'"
      },
      "template_id": "'+AppConfig.template_reset_password_id+'"
    }')

    sg = SendGrid::API.new(api_key: AppConfig.sendgrid_api)
    response = sg.client.mail._("send").post(request_body: data)
    puts response.status_code
    puts response.body
    puts response.headers
  end
end