class UserSeason < ApplicationRecord
  belongs_to :user
  belongs_to :season

  has_many :clubs, dependent: :destroy
  has_many :club_championships, through: :clubs
  has_many :def_teams, through: :clubs

  ## Settings
  # jsonb_accessor :preferences,
  #   raffle_switches: [:integer, default: nil],
  #   raffle_temp: [:jsonb, array: true, default: []]
end
