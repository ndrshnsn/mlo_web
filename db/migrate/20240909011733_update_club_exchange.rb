class UpdateClubExchange < ActiveRecord::Migration[7.2]
  def change
    rename_column :club_exchanges, :from_id, :from_club_id
    rename_column :club_exchanges, :to_club, :to_club_id
    change_column :club_exchanges, :from_club_id, :int
    change_column :club_exchanges, :to_club_id, :int
  end
end
