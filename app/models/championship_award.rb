class ChampionshipAward < ApplicationRecord
  belongs_to :championship
  belongs_to :award
  has_many :club_awards, as: :source
  has_many :rankings, as: :source, dependent: :destroy
end
