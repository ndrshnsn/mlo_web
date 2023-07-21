class PlayerTransaction < ApplicationRecord
  belongs_to :player_season
  belongs_to :from_club, :class_name => 'Club', optional: true
  belongs_to :to_club, :class_name => 'Club', optional: true

  def self.addNew(playerSeason, fromClub, toClub, transferMode, transferRate)
    # It can be nil
    fromClub_id = fromClub.nil? ? nil : fromClub.id
    toClub_id = toClub.nil? ? nil : toClub.id

    # Create new Entry in PlayerTransaction
    pTransaction = PlayerTransaction.new(
        player_season_id: playerSeason.id,
        from_club_id: fromClub_id,
        to_club_id: toClub_id,
        transfer_mode: transferMode,
        transfer_rate: transferRate
      ).save!
  end
end
