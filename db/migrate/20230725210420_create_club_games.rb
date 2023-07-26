class CreateClubGames < ActiveRecord::Migration[7.0]
  def change
    create_table :club_games do |t|
      t.references :game, null: false, foreign_key: true
      t.references :club, null: false, foreign_key: true
      t.references :player_season, null: false, foreign_key: true
      t.references :assist, null: true, foreign_key: { to_table: :player_seasons }

      t.timestamps
    end
  end
end
