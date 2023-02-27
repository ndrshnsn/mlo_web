module Push
  class Notify
    
    def self.send_push(user, message)
      begin
        Webpush.payload_send(
          message: message,
          endpoint: user.preferences["sendpoint"],
          p256dh: user.preferences["sp256dh"],
          auth: user.preferences["sauth"],
          ttl: 24 * 60 * 60,
          vapid: {
            public_key: AppConfig.vapid_pubkey,
            private_key: AppConfig.vapid_privkey
          }
        )
      rescue
        return nil
      end
    end

    def self.users_without_me_notify(type, sender, recipient, notifiable, action, comment, season_id)
      users = UserSeason.where(season_id: notifiable).where.not(user_id: recipient)
      users.each do |user|
        Notification.create(recipient: User.find(user.user_id), actor: User.find(recipient), action: action, notifiable: notifiable, season_id: season_id)
        if !user.user.onesignal_id.blank?
          webpush(user.user.onesignal_id, type, notifiable.id, comment )
        end
      end
    end

  end
end