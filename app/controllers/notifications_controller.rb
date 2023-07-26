class NotificationsController < ApplicationController
  before_action :all_notifications

  def badge
    @unread_notifications = all_notifications.unread.size >= 99 ? "99+" : all_notifications.unread.size
    @notifications = all_notifications.limit(10)
  end

  def badge_read_all
    NotificationJob.perform_later(all_notifications.first) if all_notifications.mark_as_read!

    head :ok
  end

  def all_notifications
    all_notifications = current_user.notifications.where("notifications.params -> 'league' = ?", "#{session[:league]}").order(created_at: :desc)
  end
end
