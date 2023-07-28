class ClubPlayer < ApplicationRecord
  belongs_to :club
  belongs_to :player_season, touch: true
  has_many :def_players, through: :player_season
  has_one :def_player_position, through: :player_season

  scope :order_by_position, ->(order_platform) {
    includes(:def_players, :def_player_position).where(def_player_positions: { platform: order_platform }).order(Arel.sql("def_player_positions.order ASC"))
  }
end
