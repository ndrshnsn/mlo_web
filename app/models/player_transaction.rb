class PlayerTransaction < ApplicationRecord
  belongs_to :player_season
  belongs_to :from_club, class_name: "Club", optional: true
  belongs_to :to_club, class_name: "Club", optional: true

  monetize :transfer_rate_cents, as: :transfer_rate 

  def self.new_transaction(player_season, from_club, to_club, transfer_mode, transfer_rate)
    from_club_id = from_club.nil? ? nil : from_club.id
    to_club_id = to_club.nil? ? nil : to_club.id

    PlayerTransaction.new(
      player_season_id: player_season.id,
      from_club_id: from_club_id,
      to_club_id: to_club_id,
      transfer_mode: transfer_mode,
      transfer_rate: transfer_rate
    ).save!
  end
end
