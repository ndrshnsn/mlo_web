class ManagerServices::Championship::League::Round < ApplicationService
  def initialize(championship, user)
    @championship = championship
    @user = user
  end

  def call
    ActiveRecord::Base.transaction do
      start_league_round
    end
  end

  private

  def start_league_round
    return handle_error(@championship, @championship&.error) unless @championship.update!(status: 2)

    ### NOTIFY

    OpenStruct.new(success?: true, championship: @championship, error: nil)
  end

  def notify

    # Push::Notify.group_notify(
    #   "championship",
    #   current_user.id,
    #   @championship,
    #   "start_league_round",
    #   "Turno do Camepenato #{@championship.name} Iniciado! Você já pode realizar seus jogos do turno.",
    #   true,
    #   @season.id
    # )

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

  def handle_error(season, error)
    OpenStruct.new(success?: false, championship: @championship, error: error)
  end
end
