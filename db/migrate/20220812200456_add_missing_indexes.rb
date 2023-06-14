class AddMissingIndexes < ActiveRecord::Migration[7.0]
  def change
    add_index :def_players, :slug, unique: true
    add_index :def_players, :details, using: :gin
    add_index :def_players, :platform
    add_index :def_teams, :slug, unique: true
    add_index :def_teams, :details, using: :gin
  end
end
