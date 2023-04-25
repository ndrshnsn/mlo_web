class DeviseCustomMailer < Devise::Mailer
  include Devise::Controllers::UrlHelpers
  helper MailerHelper

  default from: 'MLO <admin@mlo.app>'
  default reply_to: 'MLO <admin@mlo.app>'

  layout "mailer"

  def headers_for(action, opts)
    super.merge!({template_path: 'mailer'}) # app/views/users/mailer
  end

  def confirmation_instructions(record, token, options = {})
    super
  end

  def reset_password_instructions(record, token, options = {})
    super
  end
end
