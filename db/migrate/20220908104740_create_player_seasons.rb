class CreatePlayerSeasons < ActiveRecord::Migration[7.0]
  def change
    create_table :player_seasons do |t|
      t.references :def_player, null: false, foreign_key: true
      t.references :season, null: false, foreign_key: true
      t.jsonb :details, default: {}

      t.timestamps
    end
    add_index :player_seasons, :details, using: :gin
  end
end
