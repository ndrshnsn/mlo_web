class DefPlayerNotification < Noticed::Base
  deliver_by :database
  after_deliver :push

  param :season
  param :league
  param :icon
  param :type

  def action_cable_data
    { user_id: recipient.id }
  end

  def message
    t(".message.#{params[:type]}", season: params[:season].name)
  end

  # def url
  #   season_path(params[:season])
  # end

  def push
    if params[:push]
      Push::Notify.send_push(recipient, params[:push_message])
    end
  end

end
