class NotificationJob < ApplicationJob
  queue_as :notifications

  def perform(notification)
    all_notifications = notification.recipient.notifications.where("notifications.params -> 'league' = ?", "#{notification.recipient.preferences['active_league']}").order(created_at: :desc)
    unreadNotifications = all_notifications.unread.size >= 99 ? "99+" : all_notifications.unread.size

    html = ApplicationController.render partial: "notifications/badge_item", locals: {notifications: all_notifications.limit(10)}, formats: [:html]

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