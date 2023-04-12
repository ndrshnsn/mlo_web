class NotificationsController < ApplicationController
  def index
    @notifications = Notification.where("recipient_id = ? AND notifications.params -> 'league' = ?", current_user, "#{session[:league]}").order(created_at: :desc).limit(10)

    @unread_notifications = @notifications.unread.size
    if @unread_notifications >= 99
      @unread_notifications = "99+"
    end
  end
end
