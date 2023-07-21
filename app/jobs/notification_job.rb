class NotificationJob < ApplicationJob
  queue_as :notifications

  def perform(notification)
    unreadNotifications = Notification.where(recipient: notification.recipient).unread.size
    if unreadNotifications >= 99
      unreadNotifications = "99+"
    end

    html = ApplicationController.render partial: "notifications/notification", locals: {notifications: Notification.where(recipient: notification.recipient).order(created_at: :desc).limit(10)}, formats: [:html]

    Turbo::StreamsChannel.broadcast_replace_to(
      notification.recipient,
      :notifications,
      target: "notifications_count",
      partial: "notifications/notify_counter",
      locals: {
        unread: unreadNotifications
      }
    )

    Turbo::StreamsChannel.broadcast_update_to(
      notification.recipient,
      :notifications,
      target: "notification_list",
      html: html
    )
  end
end