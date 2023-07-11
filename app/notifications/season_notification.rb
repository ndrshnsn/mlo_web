class SeasonNotification < Noticed::Base
  deliver_by :database
  after_deliver :push

  param :season
  param :league
  param :icon
  param :type

  def action_cable_data
    {user_id: recipient.id}
  end

  def message
    t(".message.#{params[:type]}", season: params[:season].name)
  end

  def url
    season_path(params[:season])
  end

  def push
    data = {
        title: params[:push_message].split("||").first,
        body: params[:push_message].split("||").last,
        tag: 'season-notification',
        url: params[:season]
      }
    WebPushSubscription.notify(recipient, data) if params[:push]
  end
end
