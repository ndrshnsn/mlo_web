class AppServices::GlobalNotification < ApplicationService
  def initialize(league, params)
    @league = league
    @params = params
  end

  def call
    ActiveRecord::Base.transaction do
      create_global_notification
    end
  end

  private

  def create_global_notification
    notification = GlobalNotification.new(
      league_id: @league,
      title: @params[:title],
      body: @params[:body]
    )
    notification.params = {
        type: @params[:type],
        enabled: @params[:enabled],
        expire: @params[:expire]
      }
    
    return OpenStruct.new(success?: false, notification: nil, error: notification.errors) unless notification.save!
    OpenStruct.new(success?: true, notification: notification, error: nil)
  end
end
