class AppServices::Games::CriterionResult < ApplicationService
  def initialize(game1, game2, criterion)
    @game1 = game1
    @game2 = game2
    @criterion = criterion
  end

  def call
    ActiveRecord::Base.transaction do
      game_result
    end
  end

  private

  def game_result
    winlost = {}

    hGoals = @game1.hscore + @game2.vscore
    vGoals = @game2.hscore + @game1.vscore

    case @criterion
    when "outGoals"
      if hGoals == vGoals
        if @game1.vscore != @game2.vscore
          ## Check who made more out goals
          if @game1.vscore > @game2.vscore
            winlost[:win] = @game1.visitor_id
            winlost[:lost] = @game1.home_id
          elsif @game2.vscore > @game1.vscore
            winlost[:win] = @game1.home_id
            winlost[:lost] = @game1.visitor_id
          end
        elsif @game2.pvscore.to_i > @game2.phscore.to_i
          ## Sum Penalties
          winlost[:win] = @game1.home_id
          winlost[:lost] = @game1.visitor_id
        else
          winlost[:win] = @game1.visitor_id
          winlost[:lost] = @game1.home_id
        end
      elsif hGoals > vGoals
        ## Just compare Goals
        winlost[:win] = @game1.home_id
        winlost[:lost] = @game1.visitor_id
      else
        winlost[:win] = @game1.visitor_id
        winlost[:lost] = @game1.home_id
      end

    when "totalGoals"
      if hGoals == vGoals
        ## Sum Penalties
        if @game2.pvscore.to_i > @game2.phscore.to_i
          winlost[:win] = @game1.home_id
          winlost[:lost] = @game1.visitor_id
        else
          winlost[:win] = @game1.visitor_id
          winlost[:lost] = @game1.home_id
        end
      elsif hGoals > vGoals
        ## Just compare Goals
        winlost[:win] = @game1.home_id
        winlost[:lost] = @game1.visitor_id
      else
        winlost[:win] = @game1.visitor_id
        winlost[:lost] = @game1.home_id
      end
    end
    OpenStruct.new(success?: true, result: winlost)
  end

end
