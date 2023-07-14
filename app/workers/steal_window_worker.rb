class StealWindowWorker
  include Sidekiq::Worker
  sidekiq_options retry: 2

  include ApplicationHelper

  def perform(season_id, current_user_id, date)
    season = Season.find(season_id)
    user = User.find(current_user_id)

    season.update(preferences = {
        saction_transfer_window: 0,
        saction_change_wage: 0,
        saction_player_steal: 0
      }
    )

    PlayerSeason.where(season_id: season.id).each do |player_season|
      player_season.update(details = {stealed_times: 0})
    end

    Season.getClubs(season.id).each do |club|
      club.update(
        details = {
          stealed_times: 0,
          steal_times: 0,
          stealer: []
        })
    end
    
    Sidekiq::Cron::Job.find("steal_window_#{season.id}").destroy

    SeasonNotification.with(
      season: season,
      league: season.league_id,
      icon: "stack",
      type: "steal_window",
      push: true,
      push_message: "#{I18n.t("manager.seasons.steps.steal_window_end.wnotify_subject", season: season.name)}||#{I18n.t("manager.seasons.steps.steal_window_end.wnotify_text")}"
    ).deliver_later(user)

    SeasonNotification.with(
      season: season,
      league: season.league_id,
      icon: "stack",
      type: "steal_window",
      push: true,
      push_message: "#{I18n.t("manager.seasons.steps.steal_window_end.wnotify_subject", season: season.name)}||#{I18n.t("manager.seasons.steps.steal_window_end.wnotify_text")}"
    ).deliver_later(Season.valid_users(season.id))


#     = turbo_stream.update "manager_seasons", partial: "manager/seasons/details/main", locals: { season: @season }
# = render_turbo_stream_flash_messages

  end
end