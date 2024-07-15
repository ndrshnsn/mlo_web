class AppServices::Games::UpdateCard < ApplicationService
  def initialize(game, action)
    @game = game
    @action = action
  end

  def call
    ActiveRecord::Base.transaction do
      update_player_season_cards
    end
  end

  private

  def update_player_season_cards
    players = PlayerSeason.where(id: [ClubPlayer.where('club_id = ? OR club_id = ?',@game.home_id,@game.visitor_id).pluck(:player_season_id)])
    players.each do |player|
      if @action == "confirm"
        player.details["temp_ycard"] = player.details["ycard"]
        player.details["temp_rcard"] = player.details["rcard"]

        if player.details["ycard"].to_i == AppConfig.championship_cards_suspension_ycard.to_i
          player.details["ycard"] = 0
        end

        if player.details["rcard"].to_i == AppConfig.championship_cards_suspension_rcard.to_i
          player.details["rcard"] = 0
        end

      elsif @action == "cancel"
        player.details = {
          ycard: player.details["temp_ycard"],
          rcard: player.details["temp_rcard"],
          salary: player.details["salary"]
        }
      end
      return handle_error(@game, @game&.error) unless player.save!
    end
    OpenStruct.new(success?: true, game: @game, error: nil)
  end

  def handle_error(game, error)
    OpenStruct.new(success?: false, game: @game, error: error)
  end
end
