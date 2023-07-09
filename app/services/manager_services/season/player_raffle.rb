class ManagerServices::Season::PlayerRaffle < ApplicationService
  def initialize(season, user)
    @season = season
    @user = user
  end

  def call
    ActiveRecord::Base.transaction do
      start_players_raffle
    end
  end

  private

  def start_players_raffle
    season = @season
    return handle_error(season, season&.error) unless season.update!(preferences = {saction_players_choosing: 2})

    user_list = UserSeason.where(season_id: season.id).pluck(:user_id).shuffle
    order_selection = AppConfig.season_player_raffle_first_order.find { |key| key.include?(season.league.platform) }[1]

    raffle_position_order = []
    for i in 1..season.preferences["max_players"]
      if order_selection.count < i
        raffle_position_order << {position: "any"}
      elsif order_selection.count >= i
        raffle_position_order << {position: order_selection[i - 1]}
      end
    end

    raffle_position_order.each do |raffle_position|
      user_list.each do |user_id|

        user_club = User.getClub(user_id, season.id)
        user = User.find(user_id)
        user_season = UserSeason.where(user_id: user_id, season_id: season.id).first
        user_players = User.getTeamPlayers(user_id, season.id)

        if raffle_position[:position] == "any"
          raffled_player = DefPlayer.left_outer_joins(:def_player_position).where(platform: season.raffle_platform).where.not(def_players: {id: ClubPlayer.joins(:player_season, :def_players).where(player_seasons: {season_id: season.id}).pluck("def_players.id")})

          remaining = season.preferences["raffle_remaining"]
          remainingOverall = remaining.first(2)
          remainingSymbol = remaining.last(1)

          raffled_player = if remainingSymbol == "-"
            raffled_player.where("def_players.active = ? AND (def_players.details -> 'attrs' ->> 'overallRating')::int >= ? AND (def_players.details -> 'attrs' ->> 'overallRating')::int <= ?", true, season.preferences["raffle_low_over"], remainingOverall).order(Arel.sql("RANDOM()")).first
          else
            raffled_player.where("def_players.active = ? AND (def_players.details -> 'attrs' ->> 'overallRating')::int >= ?", true, remainingOverall).order(Arel.sql("RANDOM()")).first
          end
        else
          raffled_player = DefPlayer.left_outer_joins(:def_player_position).where("def_players.platform = ? AND def_players.active = ? AND def_player_positions.name = ? AND (def_players.details -> 'attrs' ->> 'overallRating')::int >= ? AND (def_players.details -> 'attrs' ->> 'overallRating')::int <= ?", season.raffle_platform, true, raffle_position[:position], season.preferences["raffle_low_over"], season.preferences["raffle_high_over"]).where.not(def_players: {id: ClubPlayer.joins(:player_season, :def_players).where(player_seasons: {season_id: season.id}).pluck("def_players.id")}).order(Arel.sql("RANDOM()")).first
        end
        player_salary = DefPlayer.getSeasonInitialSalary(season, raffled_player)
        season_player = PlayerSeason.where(def_player_id: raffled_player.id, season_id: season.id).first_or_create do |sP|
          sP.details = {
            salary: player_salary
          }
        end

        new_hired_player = ClubPlayer.new
        new_hired_player.club_id = user_club.id
        new_hired_player.player_season_id = season_player.id
        new_hired_player.save!

        PlayerSeasonFinance.create(
          player_season_id: season_player.id,
          operation: "initial_salary",
          value: player_salary,
          source: Club.find(user_club.id)
        )
        
      end
      user_list.shuffle
    end

    DefPlayerNotification.with(
      season: season,
      league: season.league_id,
      icon: "user-add",
      type: "start_players_raffle",
      push: true,
      push_message: "#{I18n.t("manager.seasons.steps.start_players_raffle.wnotify_subject", season: season.name)}||#{I18n.t("manager.seasons.steps.start_players_raffle.wnotify_text")}"
    ).deliver_later(User.joins(:user_seasons).where("user_seasons.season_id = ? AND users.preferences -> 'fake' IS NULL", season.id))

    OpenStruct.new(success?: true, season: season, error: nil)
  end

  def handle_error(season, error)
    OpenStruct.new(success?: false, season: season, error: error)
  end
end
