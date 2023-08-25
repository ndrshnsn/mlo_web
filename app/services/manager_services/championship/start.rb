class ManagerServices::Championship::Start < ApplicationService
  def initialize(championship, user)
    @championship = championship
    @user = user
  end

  def call
    ActiveRecord::Base.transaction do
      start_championship
    end
  end

  private

  def start_championship
    case @championship.ctype
    when "league"
      create_league_games
    when "cup"
    when "rounds"
    end
  end

  def create_league_games
    next_game_sequence = Championship.get_game_sequence(@championship) + 1

    listOfClubs = lClubs = ClubChampionship.where(championship_id: @championship.id).pluck(:club_id)
    firstHalf = []
    secondHalf = []
    i = 0

    listOfClubs = listOfClubs.permutation(2).to_a.shuffle
    listOfClubsHalfs = listOfClubs.count / 2
    while i < listOfClubsHalfs
      firstHalf << [listOfClubs[0][0], listOfClubs[0][1]]
      secondHalf << [listOfClubs[0][1], listOfClubs[0][0]]
      listOfClubs.delete_at(listOfClubs.find_index([listOfClubs[0][1], listOfClubs[0][0]]))
      listOfClubs.delete_at(0)
      i += 1
    end

    firstHalf.each do |game|
      Game.new(
        championship_id: @championship.id,
        home_id: game[0],
        visitor_id: game[1],
        phase: 1,
        status: 0,
        gsequence: next_game_sequence
        ).save!
      next_game_sequence += 1
    end

    if @championship.preferences["league_two_rounds"] == "on"
      secondHalf.each do |game|
        Game.new(
          championship_id: @championship.id,
          home_id: game[0],
          visitor_id: game[1],
          phase: 2,
          status: 0,
          gsequence: next_game_sequence
          ).save!
        next_game_sequence += 1
      end
    end

    return handle_error(@championship, @championship&.error) unless @championship.update!(status: 1)
    OpenStruct.new(success?: true, championship: @championship, error: nil)
  end

  def handle_error(season, error)
    OpenStruct.new(success?: false, championship: @championship, error: error)
  end
end
