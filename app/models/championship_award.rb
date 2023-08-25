class ChampionshipAward < ApplicationRecord
  belongs_to :championship
  belongs_to :award

  has_many :club_awards, foreign_key: :source_id, dependent: :destroy
end
