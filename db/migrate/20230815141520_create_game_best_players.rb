class CreateGameBestPlayers < ActiveRecord::Migration[7.0]
  def change
    create_table :game_best_players do |t|
      t.references :club, null: true, foreign_key: true
      t.references :player_season, null: false, foreign_key: true
      t.references :game, null: false, foreign_key: true

      t.timestamps
    end
  end
end
