class CreateDefPlayers < ActiveRecord::Migration[7.0]
  def change
    create_table :def_players do |t|
      t.string :name
      t.integer :height
      t.integer :weight
      t.integer :age
      t.string :foot
      t.boolean :active, default: true
      t.string :platform
      t.string :slug
      t.jsonb :details, default: {}
      t.references :def_player_position, null: false, foreign_key: true
      t.references :def_country, null: false, foreign_key: true

      t.timestamps
    end
  end
end
