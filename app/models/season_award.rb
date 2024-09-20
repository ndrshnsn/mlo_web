class SeasonAward < ApplicationRecord
  belongs_to :season
  belongs_to :award

  has_many :club_awards, foreign_key: :source_id, dependent: :destroy, inverse_of: :season_awards
  has_many :rankings, as: :source, dependent: :destroy
end
