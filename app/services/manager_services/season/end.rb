class ManagerServices::Season::End < ApplicationService
  def initialize(season, user, params)
    @season = season
    @user = user
    @params = params
  end

  def call
    ActiveRecord::Base.transaction do
      end_season
    end
  end

  private

  def end_season
    season = @season
    open_championships = Championship.get_running(season.id)
    open_games = Game.get_running(season.id)
    return handle_error(season, "end.previous_running") unless open_championships.size == 0 && open_games.size == 0

    dismiss_players = @params[:season_end].has_key?(:dismiss_players) ? true : false
    pay_wages = @params[:season_end].has_key?(:pay_wages) ? true : false
    clear_club_balance = @params[:season_end].has_key?(:clear_club_balance) ? true : false

    season.user_seasons.each do |user_season|
      club = user_season.clubs.first
      players = User.getTeamPlayers(user_season.user_id, season.id).includes(player_season: [def_player: :def_player_position])

      players.each do |club_player|
        ClubFinance.create(club_id: club.id, operation: "pay_wage", value: club_player.player_season.details["salary"], source: club_player.player_season) if pay_wages

        if dismiss_players
          PlayerTransaction.new_transaction(club_player.player_season, club, nil, "dismiss", 0)
          club_player.destroy!
        end
      end

      ClubFinance.create(club_id: club.id, operation: "clear_club_balance", value: 0, balance: 0, source: @season) if clear_club_balance
    end

    return handle_error(season, season&.error) unless season.update!(status: 2)
    
    season.update(preferences = {
      saction_players_choosing: 2,
      saction_transfer_window: 2,
      saction_player_steal: 2
    })

    SeasonNotification.with(
      season: season,
      league: season.league_id,
      icon: "stack",
      type: "end",
      push: true,
      push_message: "#{I18n.t("manager.seasons.steps.end.wnotify_subject", season: season.name)}||#{I18n.t("manager.seasons.steps.end.wnotify_text")}"
    ).deliver_later(@user)

    SeasonNotification.with(
      season: season,
      league: season.league_id,
      icon: "stack",
      type: "end",
      push: true,
      push_message: "#{I18n.t("manager.seasons.steps.end.wnotify_subject", season: season.name)}||#{I18n.t("manager.seasons.steps.end.wnotify_text")}"
    ).deliver_later(User.joins(:user_seasons).where("user_seasons.season_id = ? AND users.preferences -> 'fake' IS NULL", season.id))

    OpenStruct.new(success?: true, season: season, error: nil)
  end

  def handle_error(season, error)
    OpenStruct.new(success?: false, season: season, error: error)
  end
end