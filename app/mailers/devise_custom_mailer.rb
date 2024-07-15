class DeviseCustomMailer < Devise::Mailer
  include Devise::Controllers::UrlHelpers
  helper MailerHelper

  default from: AppConfig.mail_admin
  default reply_to: AppConfig.mail_admin

  layout "mailer"

  def headers_for(action, opts)
    super.merge!({template_path: 'mailer/devise'})
  end

  def confirmation_instructions(record, token, options = {})
    super
  end

  def reset_password_instructions(record, token, options = {})
    super
  end
end
