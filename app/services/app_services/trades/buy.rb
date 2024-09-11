class AppServices::Trades::Buy < ApplicationService
  def initialize(club, season, player)
    @club = club
    @season = season
    @player = player
  end

  def call
    ActiveRecord::Base.transaction do
      confirm_buy
    end
  end

  private

  def confirm_buy
    club_players = Club.get_players(@club.id, @season.preferences["raffle_platform"])
    club_funds = Club.getFunds(@club.id)

    return handle_error(@club, ".max_player_limit") unless club_players.size < @season.preferences["max_players"]
    season_player = PlayerSeason.where(def_player_id: @player.id, season_id: @season.id).first_or_create! do |sp|
      sp.salary = DefPlayer.getSeasonInitialSalary(@season, @player)
    end
    season_player_pass = PlayerSeason.getPlayerPass(season_player, @season)

    club_max_wage = @season.club_max_total_wage - Club.getTeamTotalWage(@club.id)
    return handle_error(@club, ".max_wage_limit") unless season_player.salary < club_max_wage

    available_funds = (club_funds >= season_player_pass || @season.preferences["allow_negative_funds"] == "on")
    return handle_error(@club, ".no_club_funds") unless available_funds

    new_player = ClubPlayer.new
    new_player.club_id = @club.id
    new_player.player_season_id = season_player.id
    return handle_error(@club, new_player&error) unless new_player.save!

    PlayerTransaction.new_transaction(season_player, nil, @club, "hire", season_player_pass)
    player_season_finance = PlayerSeasonFinance.where(player_season_id: season_player.id).order(created_at: :desc)
    if player_season_finance.size > 0
      PlayerSeasonFinance.create!(
        operation: "player_hire",
        value: player_season_finance.first.value,
        source: @club,
        player_season_id: season_player.id
      )
    else
      PlayerSeasonFinance.create!(
        operation: "initial_salary",
        value: season_player.salary,
        source: @club,
        player_season_id: season_player.id
      )
    end
    ClubFinance.create!(club_id: @club.id, operation: "player_hire", value: season_player_pass, source: season_player)

    Trades::BuyJob.perform_later(Rails.configuration.playerdb_prefix, @club.user_season.season.id, season_player)

    OpenStruct.new(success?: true, player: @club, error: nil)
  end

  def handle_error(club, error)
    OpenStruct.new(success?: false, player: @club, error: error)
  end
end
