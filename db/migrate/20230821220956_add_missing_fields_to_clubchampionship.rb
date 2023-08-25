class AddMissingFieldsToClubchampionship < ActiveRecord::Migration[7.0]
  def change
    add_column :club_championships, :games, :integer, default: 0
    add_column :club_championships, :wins, :integer, default: 0
    add_column :club_championships, :draws, :integer, default: 0
    add_column :club_championships, :losses, :integer, default: 0
    add_column :club_championships, :goalsfor, :integer, default: 0
    add_column :club_championships, :goalsagainst, :integer, default: 0
    add_column :club_championships, :goalsdiff, :integer, default: 0
    add_column :club_championships, :points, :integer, default: 0
    add_column :club_championships, :gamerate, :integer, default: 0
    add_column :club_championships, :group, :integer
  end
end
