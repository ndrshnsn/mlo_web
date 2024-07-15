class GameBestPlayer < ApplicationRecord
  belongs_to :club, optional: true
  belongs_to :player_season
  belongs_to :game
end
