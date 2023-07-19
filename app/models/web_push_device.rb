class WebPushDevice < ApplicationRecord
  belongs_to :user

  def self.notify(recipient, msg)
    if recipient && recipient.web_push_devices.any?
      recipient.web_push_devices.each do |sub|
        WebPush.payload_send(
          message: {
            title: "MLO :: " + msg[:title],
            text: msg[:body],
            tag:  msg[:tag]
          }.to_json,
          endpoint: sub.endpoint,
          p256dh: sub.p256dh_key,
          auth: sub.auth_key,
          vapid: {
            public_key: ENV['VAPID_PUBLIC_KEY'],
            private_key: ENV['VAPID_PRIVATE_KEY']
          }
        )
        rescue => error
          Rails.logger.warn("Error sending browser notification: #{error.inspect}")
          false
      end
    end
  end

  def self.users_without_me_notify(type, sender, recipient, notifiable, action, comment, season_id)
    users = UserSeason.where(season_id: notifiable).where.not(user_id: recipient)
    users.each do |user|
      Notification.create(recipient: User.find(user.user_id), actor: User.find(recipient), action: action, notifiable: notifiable, season_id: season_id)
      if user.user.onesignal_id.present?
        webpush(user.user.onesignal_id, type, notifiable.id, comment)
      end
    end
  end

end
