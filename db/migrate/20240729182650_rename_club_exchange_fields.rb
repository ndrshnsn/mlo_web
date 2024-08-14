class RenameClubExchangeFields < ActiveRecord::Migration[7.1]
  def change
    rename_column :club_exchanges, :from_club_id, :from_id
    rename_column :club_exchanges, :to_club_id, :to_club
  end
end
