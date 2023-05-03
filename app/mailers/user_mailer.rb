class UserMailer < ApplicationMailer
  default template_path: 'mailer/user'

  def request_league
    @user = params[:user]
    @league_params = params[:params]
    mail(to: @user.email, subject: t('mailer.user.request_league.subject'))
  end
end
