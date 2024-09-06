class AppServices::Trades::Fire < ApplicationService
  def initialize(club, season, player)
    @club = club
    @season = season
    @player = player
  end

  def call
    ActiveRecord::Base.transaction do
      fire_player
    end
  end

  private

  def fire_player
    player = @player.player_season
    club_players = Club.get_players(@club.id, @season.preferences["raffle_platform"])
    club_funds = Club.getFunds(@club.id)
    fire_tax = Season.get_player_fire_tax(@season.id, player.id)
    result_funds = club_funds - fire_tax

    return handle_error(@club, ".fire_not_permitted") unless @season.preferences["allow_fire_player"] == "on"

    return handle_error(@club, ".negative_funds") if result_funds < 0 && @season.preferences["allow_negative_funds"] != "on"

    return handle_error(@club, ".min_player_limit") unless club_players.size > @season.preferences["min_players"]

    club_finance = ClubFinance.create(club_id: @club.id, operation: "fire_tax", value: fire_tax, source: player)
    return handle_error(@club, club_finance&error) unless club_finance

    player_season_finance = PlayerSeasonFinance.create(player_season_id: player.id, operation: "player_dismiss", value: fire_tax, source: @club)
    return handle_error(@club, player_season_finance&error) unless player_season_finance

    player_transaction = PlayerTransaction.new_transaction(player, @club, nil, "dismiss", fire_tax)
    return handle_error(@club, player_transaction&error) unless player_transaction

    return handle_error(@club, @player&error) unless @player.destroy

    Trades::BuyJob.perform_later(Rails.configuration.playerdb_prefix, @club.user_season.season.id, player)

    OpenStruct.new(success?: true, player: @club, error: nil)
  end

  def handle_error(club, error)
    OpenStruct.new(success?: false, player: @club, error: error)
  end
end