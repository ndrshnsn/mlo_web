class CreateGameCards < ActiveRecord::Migration[7.0]
  def change
    create_table :game_cards do |t|
      t.references :game, null: false, foreign_key: true
      t.references :player_season, null: false, foreign_key: true
      t.references :club, null: false, foreign_key: true
      t.boolean :ycard
      t.boolean :rcard

      t.timestamps
    end
  end
end
