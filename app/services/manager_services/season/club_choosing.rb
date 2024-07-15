class ManagerServices::Season::ClubChoosing < ApplicationService
  include ApplicationHelper

  def initialize(season, user)
    @season = season
    @user = user
  end

  def call_start
    ActiveRecord::Base.transaction do
      start
    end
  end

  def call_stop
    ActiveRecord::Base.transaction do
      stop
    end
  end

  private

  def start
    season = @season
    return handle_error(season, season&.error) unless season.update!(saction_clubs_choosing: 1)

    ## Create Global Notification
    params = {
      title: I18n.t("global_notify.choose_clubs_open_title"),
      body: I18n.t("global_notify.choose_clubs_open_desc_html"),
      type: "info",
      enabled: true
    }
    AppServices::GlobalNotification.call(season.league_id, params)

    SeasonNotification.with(
      season: season,
      league: season.league_id,
      icon: "stack",
      type: "start_clubs_choosing",
      push: true,
      push_message: "#{I18n.t("manager.seasons.steps.start_club_choosing.wnotify_subject", season: season.name)}||#{I18n.t("manager.seasons.steps.start_club_choosing.wnotify_text")}"
    ).deliver_later(@user)

    SeasonNotification.with(
      season: season,
      league: season.league_id,
      icon: "stack",
      type: "start_clubs_choosing",
      push: true,
      push_message: "#{I18n.t("manager.seasons.steps.start_club_choosing.wnotify_subject", season: season.name)}||#{I18n.t("manager.seasons.steps.start_club_choosing.wnotify_text")}"
    ).deliver_later(User.joins(:user_seasons).where("user_seasons.season_id = ? AND users.preferences -> 'fake' IS NULL", season.id))

    OpenStruct.new(success?: true, season: season, error: nil)
  end

  def stop
    season = @season
    platform = @season.raffle_platform
    return handle_error(season, season&.error) unless season.update!(saction_clubs_choosing: 2)

    ordered_choosing_queue = UserSeason.where(season_id: season.id).pluck(:user_id)
    ordered_choosing_queue.each do |cQueue|
      user_club = User.getClub(cQueue, season.id)
      user = User.find(cQueue)
      user_season = UserSeason.where(user_id: user.id, season_id: @season.id).first
      if user_club.nil?
        excluded = Club.joins(:user_season).where(user_seasons: {season_id: season.id}).pluck(:def_team_id)
        new_club = DefTeam.where(nation: false, active: true).where("platforms ILIKE ?", "%#{platform}%").where.not(id: excluded).order(Arel.sql("RANDOM()")).first

        formation_pos = []
        team_formations[0][:pos].each do |tF|
          formation_pos << {pos: tF, player: ""}
        end

        club = Club.new
        club.def_team_id = new_club.id
        club.user_season_id = user_season.id
        club.details = {
          team_formation: 0,
          formation_pos: formation_pos
        }
        club.save!

        ClubFinance.create!(club_id: club.id, operation: "initial_funds", value: season.preferences["club_default_earning"].to_i, balance: season.preferences["club_default_earning"].to_i, source: season)

        SeasonNotification.with(
          season: season,
          league: season.league_id,
          icon: "stack",
          push: true,
          push_type: "user",
          push_message: "#{I18n.t("manager.seasons.steps.stop_club_choosing.wnotify_subject", season: season.name)}||#{I18n.t("manager.seasons.steps.stop_club_choosing.wnotify_text")}",
          type: "club_choosed"
        ).deliver_later(user)
      end
    end

    ## Remove Global Notification
    GlobalNotification.disable(@season.league_id)

    SeasonNotification.with(
      season: season,
      league: season.league_id,
      icon: "stack",
      type: "stop_clubs_choosing",
      push: false,
      push_message: I18n.t("manager.seasons.steps.stop_club_choosing.wnotify_subject", season: season.name)
    ).deliver_later(@user)

    OpenStruct.new(success?: true, season: season, error: nil)
  end

  def handle_error(season, error)
    OpenStruct.new(success?: false, season: season, error: error)
  end
end
