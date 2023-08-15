class ChampionshipAward < ApplicationRecord
  belongs_to :championship
  belongs_to :award
end
