class ManagerServices::Season::Transfer < ApplicationService
  def initialize(season, user, step)
    @season = season
    @user = user
    @step = step
  end

  def call
    ActiveRecord::Base.transaction do
      wage_action
    end
  end

  private

  def wage_action
    season = @season
    if @step == "start"
      step = 1
      not_type = "start_transfer_window"
      not_type_user = "start_transfer_window_user"
      msg_text = I18n.t("manager.seasons.steps.start_transfer_window.wnotify_text")
    elsif @step == "stop"
      step = 0
      not_type = "stop_transfer_window"
      not_type_user = "stop_transfer_window_user"
      msg_text = I18n.t("manager.seasons.steps.stop_transfer_window.wnotify_text")
    end
    return handle_error(season, season&.error) unless season.update!(preferences = {saction_transfer_window: step})

    SeasonNotification.with(
      season: season,
      league: season.league_id,
      icon: "stack",
      type: not_type,
      push: true,
      push_message: "#{I18n.t("manager.seasons.steps.start_transfer_window.wnotify_subject", season: season.name)}||#{msg_text}"
    ).deliver_later(@user)

    SeasonNotification.with(
      season: season,
      league: season.league_id,
      icon: "stack",
      type: not_type_user,
      push: true,
      push_message: "#{I18n.t("manager.seasons.steps.start_transfer_window.wnotify_subject", season: season.name)}||#{msg_text}"
    ).deliver_later(User.joins(:user_seasons).where("user_seasons.season_id = ? AND users.preferences -> 'fake' IS NULL", season.id))

    OpenStruct.new(success?: true, season: season, error: nil)
  end

  def handle_error(season, error)
    OpenStruct.new(success?: false, season: season, error: error)
  end
end
