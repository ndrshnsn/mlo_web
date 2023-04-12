class Notification < ApplicationRecord
  include Noticed::Model
  belongs_to :recipient, polymorphic: true

  after_commit :broadcast_to_recipient

  def broadcast_to_recipient
    unreadNotifications = Notification.where(recipient: recipient).unread.size
    if unreadNotifications >= 99
      unreadNotifications = "99+"
    end

    html = ApplicationController.render partial: "notifications/notification", locals: {notifications: Notification.where(recipient: recipient).order(created_at: :desc).limit(10)}, formats: [:html]

    broadcast_replace_to(
      recipient,
      :notifications,
      target: "notifications_count",
      partial: "notifications/notify_counter",
      locals: {
        unread: unreadNotifications
      }
    )

    broadcast_update_to(
      recipient,
      :notifications,
      target: "notification_list",
      html: html
    )
  end
end
