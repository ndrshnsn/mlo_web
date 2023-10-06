class RemoveUniqueSlugIndexFromDefPlayers < ActiveRecord::Migration[7.0]
  def change
    remove_index :def_players, column: :slug, unique: true
    add_index :def_players, :slug, unique: false
  end
end
