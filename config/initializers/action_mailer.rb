ActionMailer::Base.smtp_settings = {
  address: 'smtp.gmail.com',
  port: 587,
  domain: 'gmail.com',
  user_name: Rails.application.credentials.dig(:sendmail, :username),
  password: Rails.application.credentials.dig(:sendmail, :password),
  authentication: :login,
  enable_starttls_auto: true
}