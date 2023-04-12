class Game < ApplicationRecord
  include Hashid::Rails

  belongs_to :championship
  belongs_to :visitor, class_name: "Club"
  belongs_to :home, class_name: "Club"
  belongs_to :eresults, class_name: "Club", optional: true
  belongs_to :player_season, optional: true
  # has_one :club_bestplayer, dependent: :destroy
  # has_many :game_contests, dependent: :destroy
  # has_many :club_games, dependent: :destroy
  # has_many :game_cards, dependent: :destroy
  # has_many :club_finances, foreign_key: :source_id, dependent: :destroy
  # has_many :notifications, foreign_key: :notifiable_id, dependent: :destroy
  # has_many :rankings, foreign_key: :source_id, dependent: :destroy

  ##
  # Return Winner and Lost of Game
  def self.getWinnerLost(game1, game2)
    winlost = {}

    ## Check for Game results between 2 teams
    resultCrit = game2.championship.preferences["league_criterion"]

    hGoals = game1.hscore + game2.vscore
    vGoals = game2.hscore + game1.vscore

    ## Check Result
    if resultCrit == "outGoals"
      if hGoals == vGoals
        if game1.vscore != game2.vscore
          ## Check who made more out goals
          if game1.vscore > game2.vscore
            winlost[:win] = game1.visitor_id
            winlost[:lost] = game1.home_id
          elsif game2.vscore > game1.vscore
            winlost[:win] = game1.home_id
            winlost[:lost] = game1.visitor_id
          end
        elsif game2.pvscore.to_i > game2.phscore.to_i
          ## Sum Penalties
          winlost[:win] = game1.home_id
          winlost[:lost] = game1.visitor_id
        else
          winlost[:win] = game1.visitor_id
          winlost[:lost] = game1.home_id
        end
      elsif hGoals > vGoals
        ## Just compare Goals
        winlost[:win] = game1.home_id
        winlost[:lost] = game1.visitor_id
      else
        winlost[:win] = game1.visitor_id
        winlost[:lost] = game1.home_id
      end

    elsif resultCrit == "totalGoals"
      if hGoals == vGoals
        ## Sum Penalties
        if game2.pvscore.to_i > game2.phscore.to_i
          winlost[:win] = game1.home_id
          winlost[:lost] = game1.visitor_id
        else
          winlost[:win] = game1.visitor_id
          winlost[:lost] = game1.home_id
        end
      elsif hGoals > vGoals
        ## Just compare Goals
        winlost[:win] = game1.home_id
        winlost[:lost] = game1.visitor_id
      else
        winlost[:win] = game1.visitor_id
        winlost[:lost] = game1.home_id
      end
    end

    winlost
  end

  ##
  # Return Translated Game Phase
  def self.translatePhase(game)
    # Phase list
    phase = {
      firstRound: ["Turno", "secondary"],
      secondRound: ["Returno", "secondary"],
      semifinals: ["Semifinal", "warning"],
      finals: ["Final", "success"],
      "3rd4th": ["3o/4o Lugar", "info"]
    }
    phase[:"#{game.phase}"]
  end

  ## Game Status
  def self.getStatus(game_id)
    # status list
    status = {
      "0": ["not_started", "Não Iniciado", "secondary"],
      "1": ["running", "Em Andamento", "info"],
      "2": ["running", "Confirmação Resultado", "warning"],
      "3": ["running", "Contestado", "danger"],
      "4": ["finished", "Encerrado", "primary"]
    }
    game = Game.find(game_id)
    status[:"#{game.status}"]
  end
end
