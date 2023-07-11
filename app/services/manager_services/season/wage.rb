class ManagerServices::Season::Wage < ApplicationService
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
      not_type = "start_wage"
      not_type_user = "start_wage_user"
      msg_text = I18n.t("manager.seasons.steps.start_change_wage.wnotify_text")
    elsif @step == "stop"
      step = 0
      not_type = "stop_wage"
      not_type_user = "stop_wage_user"
      msg_text = I18n.t("manager.seasons.steps.stop_change_wage.wnotify_text")
    end
    return handle_error(season, season&.error) unless season.update!(preferences = {saction_change_wage: step})

    SeasonNotification.with(
      season: season,
      league: season.league_id,
      icon: "stack",
      type: not_type,
      push: true,
      push_message: "#{I18n.t("manager.seasons.steps.start_change_wage.wnotify_subject", season: season.name)}||#{msg_text}"
    ).deliver_later(@user)

    SeasonNotification.with(
      season: season,
      league: season.league_id,
      icon: "stack",
      type: not_type_user,
      push: false,
      push_message: "#{I18n.t("manager.seasons.steps.stop_change_wage.wnotify_subject", season: season.name)}||#{msg_text}"
    ).deliver_later(User.joins(:user_seasons).where("user_seasons.season_id = ? AND users.preferences -> 'fake' IS NULL", season.id))

    OpenStruct.new(success?: true, season: season, error: nil)
  end

  def handle_error(season, error)
    OpenStruct.new(success?: false, season: season, error: error)
  end
end
