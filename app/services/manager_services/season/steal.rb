class ManagerServices::Season::Steal < ApplicationService
  def initialize(season, user)
    @season = season
    @user = user
  end

  def call
    ActiveRecord::Base.transaction do
      start_steal_window
    end
  end

  private

  def start_steal_window
    season = @season
    return handle_error(season, season&.error) unless season.update!(
      saction_transfer_window: 0,
      saction_player_steal: 1,
      saction_change_wage: 0
      )

    PlayerSeason.where(season_id: season.id).each do |player_season|
      player_season.update(details = {stealed_times: 0})
    end

    season.clubs.each do |club|
      club.update(
        details = {
          stealed_times: 0,
          steal_times: 0,
          stealer: []
        })
    end

    time_of = Time.now + (season.preferences['steal_window_start'].to_i*60 + rand(0..season.preferences['steal_window_end'].to_i*60)).minutes
    job = Sidekiq::Cron::Job.new(name: "player_steal_window_#{season.id}", cron: "#{time_of.min} #{time_of.hour} * * *", class: 'StealWindowWorker', date_as_argument: true, args: [season.id, @user.id])
    return handle_error(season, season&.error) unless job.valid?

    SeasonNotification.with(
      season: season,
      league: season.league_id,
      icon: "stack",
      type: "steal_window",
      push: true,
      push_message: "#{I18n.t("manager.seasons.steps.steal_window.wnotify_subject", season: season.name)}||#{I18n.t("manager.seasons.steps.steal_window.wnotify_text")}"
    ).deliver_later(@user)

    SeasonNotification.with(
      season: season,
      league: season.league_id,
      icon: "stack",
      type: "steal_window",
      push: true,
      push_message: "#{I18n.t("manager.seasons.steps.steal_window.wnotify_subject", season: season.name)}||#{I18n.t("manager.seasons.steps.steal_window.wnotify_text")}"
    ).deliver_later(User.joins(:user_seasons).where("user_seasons.season_id = ? AND users.preferences -> 'fake' IS NULL", season.id))

    OpenStruct.new(success?: true, season: season, error: nil)
  end

  def handle_error(season, error)
    OpenStruct.new(success?: false, season: season, error: error)
  end
end
