class CreateDefPlayerPositions < ActiveRecord::Migration[7.0]
  def change
    create_table :def_player_positions do |t|
      t.string :name
      t.integer :order
      t.string :platform, default: "null"

      t.timestamps
    end
  end
end
