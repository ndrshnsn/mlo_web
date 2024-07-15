class GameCard < ApplicationRecord
  belongs_to :game
  belongs_to :player_season
  belongs_to :club
end
