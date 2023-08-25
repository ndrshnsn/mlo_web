class RemoveWoFromGamesAddSubtype < ActiveRecord::Migration[7.0]
  def change
    remove_column :games, :wo
    add_column :games, :subtype, :integer, default: 0
  end
end
