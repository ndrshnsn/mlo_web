class ManagerServices::Championship::Club < ApplicationService
  def initialize(championship, user, params)
    @championship = championship
    @user = user
    @params = params
  end

  def call
    ActiveRecord::Base.transaction do
      add_clubs_to_championship
    end
  end

  private

  def add_clubs_to_championship
    case @championship.ctype
    when "league"
      clubs = @params[:championship_clubs]
      clubs.each do |club|
        return handle_error(@championship, @championship&.error) unless ClubChampionship.create(club_id: club, championship_id: @championship.id)
      end
    end

    OpenStruct.new(success?: true, championship: @championship, error: nil)
  end

  def handle_error(championship, error)
    OpenStruct.new(success?: false, championship: championship, error: error)
  end

  def notify
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
  end
end
