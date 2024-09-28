class AppServices::Steal < ApplicationService
  def initialize(season, buyer, club_from, player, user)
    @season = season
    @buyer = buyer
    @player = player
    @club_from = club_from
    @user = user
  end

  def call
    ActiveRecord::Base.transaction do
      steal_player
    end
  end

  private

  def steal_player

    user_club = Club.find(@club_from)
    club_players = user_club.club_players

    return handle_error(user_club, ".no_slots_available") unless club_players.size < @season.preferences["max_players"].to_i

    player = DefPlayer.find_by(slug: @player, platform: @season.raffle_platform)
    player_season = PlayerSeason.find_by(def_player_id: player.id, season_id: @season.id)
    max_wage_allowed = @season.club_max_total_wage - Club.getTeamTotalWage(@club_from)
    newSalary = ((@season.preferences["add_value_after_steal"].to_i.to_f/100) * player_season.salary) + player_season.salary

    return handle_error(user_club, ".max_wage_limit") unless newSalary <= max_wage_allowed
      
    return handle_error(user_club, ".no_club_funds") unless (newSalary * @season.preferences["player_value_earning_relation"]) >= PlayerSeason.getPlayerPass(player_season, @season) || @season.preferences['allow_negative_funds'] == "on"

    max_steals_per_user = @season.preferences["max_steals_per_user"].to_i
    max_stealed_players = @season.preferences["max_stealed_players"].to_i
    max_steals_same_player = @season.preferences["max_steals_same_player"].to_i
    player_season_stealed_times = player_season.details['stealed_times'].to_i
    club_steal_times = user_club.details['steal_times'].to_i
    club_stealed = Club.find(player_season.club_players.first.club_id)
    stealer = club_stealed.details['stealer']
    stealerCount = stealer.tally[user_club.id].nil? ? 0 : stealer.tally[user_club.id]

    return handle_error(user_club, ".max_stealed_players") unless club_steal_times < max_stealed_players

    return handle_error(user_club, ".max_steals_same_player") unless player_season_stealed_times <= max_steals_same_player

    return handle_error(user_club, ".max_steals_per_user") unless stealerCount < max_steals_per_user
      
    club_finance = ClubFinance.create(club_id: club_stealed.id, operation: "player_stealed", value: PlayerSeason.getPlayerPass(player_season, @season), source: player_season)

    return handle_error(user_club, club_finance&errors) unless club_finance.save!

    return handle_error(user_club, ".max_steals_per_user") unless player_season.update(salary: newSalary)

    player_season_finance = PlayerSeasonFinance.where(player_season_id: player_season.id).order(created_at: :desc).new(
      operation: "player_steal",
      value: newSalary,
      source: user_club
    )
    return handle_error(user_club, club_finance&errors) unless player_season_finance.save!

    club_finance = ClubFinance.new(club_id: user_club.id, operation: "player_steal", value: newSalary*@season.preferences["player_value_earning_relation"].to_i, source: player_season)
    return handle_error(user_club, club_finance&errors) unless club_finance.save!

    stealer << user_club.id
    stealTimes = user_club.details['steal_times'].to_i
    user_club.update(
      details = {
        steal_times: stealTimes + 1
      })

    stealedTimes = player_season.details['stealed_times'].to_i
    player_season.update(
      details = {
        stealed_times: stealedTimes + 1
      })

    club_stealed.update(
      details = {
        stealer: stealer 
      })

    club_stealed_stealTimes = club_stealed.details['steal_times'].to_i > 0 ? club_stealed.details['steal_times'].to_i - 1 : 0
    club_stealed.update(
      details = {
        steal_times: club_stealed_stealTimes
      })

    club_player = ClubPlayer.find_by(player_season_id: player_season.id)
    return handle_error(user_club, club_finance&errors) unless club_player.destroy!

    club_player = ClubPlayer.create(club_id: user_club.id, player_season_id: player_season.id)
    return handle_error(user_club, club_finance&errors) unless club_player.save!
    
    player_transaction = PlayerTransaction.new_transaction(player_season, club_stealed, user_club, "steal", newSalary*@season.preferences["player_value_earning_relation"].to_i)

    StealJob.perform_later(Rails.configuration.playerdb_prefix, @season.id, player_transaction, @user)

    OpenStruct.new(success?: true, club: user_club, error: nil)
  end

  def handle_error(club, error)
    OpenStruct.new(success?: false, club: club, error: error)
  end
end