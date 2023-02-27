class PlayerSeasonFinance < ApplicationRecord
  belongs_to :player_season
  belongs_to :source, polymorphic: true
end
