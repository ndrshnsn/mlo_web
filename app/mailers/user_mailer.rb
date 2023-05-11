class UserMailer < ApplicationMailer
  default template_path: 'mailer/user'

  def request_league
    @user = params[:user]
    @league_params = params[:params]
    mail(to: AppConfig.mail_admin, subject: t('mailer.user.request_league.subject'))
  end

  def join_league
    @user = params[:user]
    @league = params[:league]
    mail(to: @user.email, subject: t('mailer.user.join_league.subject', league_name: @league.name))
  end
end
