class ChampionshipNotification < Noticed::Base
  deliver_by :database
  after_deliver :push

  param :championship
  param :icon
  param :type

  def action_cable_data
    {user_id: recipient.id}
  end

  def message
    t(".message.#{params[:type]}", championship: params[:championship].name)
  end

  def url
    championship_path(params[:championship])
  end

  def push
    if params[:push]
      Push::Notify.send_push(recipient, params[:push_message])
    end
  end
end
