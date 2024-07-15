class ApplicationMailer < ActionMailer::Base
  helper MailerHelper
  default from: AppConfig.mail_admin
  default reply_to: AppConfig.mail_admin
  layout "mailer"
end
