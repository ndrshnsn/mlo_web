class ChampionshipPosition < ApplicationRecord
  belongs_to :championship
  belongs_to :club
end
