class ManagerServices::Season::Start < ApplicationService
  def initialize(season, user)
    @season = season
    @user = user
  end

  def call
    ActiveRecord::Base.transaction do
      start_season
    end
  end

  private

  def start_season
    season = @season
    return handle_error(season, season&.error) unless season.update!(status: 1)

    SeasonNotification.with(
      season: season,
      league: season.league_id,
      icon: "stack",
      type: "start",
      push: true,
      push_message: "#{I18n.t("manager.seasons.steps.start.wnotify_subject", season: season.name)}||#{I18n.t("manager.seasons.steps.start.wnotify_text")}"
    ).deliver_later(@user)

    SeasonNotification.with(
      season: season,
      league: season.league_id,
      icon: "stack",
      type: "start",
      push: true,
      push_message: "#{I18n.t("manager.seasons.steps.start.wnotify_subject", season: season.name)}||#{I18n.t("manager.seasons.steps.start.wnotify_text")}"
    ).deliver_later(User.joins(:user_seasons).where("user_seasons.season_id = ? AND users.preferences -> 'fake' IS NULL", season.id))

    OpenStruct.new(success?: true, season: season, error: nil)
  end

  def handle_error(season, error)
    OpenStruct.new(success?: false, season: season, error: error)
  end
end
