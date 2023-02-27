class ClubPlayer < ApplicationRecord
  belongs_to :club
  belongs_to :player_season, touch: true
  has_many :def_players, through: :player_season
  has_one :def_player_position, through: :player_season
  #has_many :notifications, foreign_key: :notifiable_id

  scope :order_by_position, -> {
    includes(:def_players, :def_player_position).order(Arel.sql('def_player_positions.order ASC'))
  }
end
