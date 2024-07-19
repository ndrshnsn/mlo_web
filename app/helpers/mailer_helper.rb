module MailerHelper
  def email_image_tag(image, **options)
    attachments[image] = File.read(Rails.root.join("app/frontend/images/#{image}"))
    image_tag attachments[image].url, **options
  end
end