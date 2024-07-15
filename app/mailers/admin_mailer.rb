class AdminMailer < ApplicationMailer
  default template_path: 'mailer/admin'

  def create_league
    @league = params[:league]
    mail(to: @league.user.email, subject: t('mailer.admin.create_league.subject'))
  end
end
