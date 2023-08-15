class SeasonAward < ApplicationRecord
  belongs_to :season
  belongs_to :award
end
