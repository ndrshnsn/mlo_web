class NotificationsController < ApplicationController
  def index
    @notifications = Notification.where("recipient_id = ? AND notifications.params -> 'league' = ?", current_user, "#{session[:league]}").order(created_at: :desc).limit(10)

    @unreadNotifications = @notifications.unread.size
    if @unreadNotifications >= 99
      @unreadNotifications = "99+"
    end
  end
end