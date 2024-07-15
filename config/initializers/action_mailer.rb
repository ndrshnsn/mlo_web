ActionMailer::Base.smtp_settings = {
  user_name: "apikey", # do not change this field
  password: ENV['SENDGRID_API'],
  domain: "mlo.app", # change it to your own domain
  address: "smtp.sendgrid.net",
  port: 587,
  authentication: :plain,
  enable_starttls_auto: true
}