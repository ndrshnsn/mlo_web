class NotificationsController < ApplicationController

  def index
    all_notifications = Notification.includes(:recipient).where("recipient_id = ? AND notifications.params -> 'league' = ?", current_user, "#{session[:league]}").order(created_at: :desc)

    @unread_notifications = all_notifications.unread.size >= 99 ? "99+" : all_notifications.unread.size
    @notifications = all_notifications.limit(10)
  end
end
