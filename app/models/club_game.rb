class ClubGame < ApplicationRecord
  belongs_to :game
  belongs_to :club
  belongs_to :player_season
  belongs_to :assist, class_name: "PlayerSeason", optional: true
end
