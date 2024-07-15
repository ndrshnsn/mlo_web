class CreateChampionshipPositions < ActiveRecord::Migration[7.0]
  def change
    create_table :championship_positions do |t|
      t.references :championship, null: false, foreign_key: true
      t.references :club, null: false, foreign_key: true
      t.integer :position

      t.timestamps
    end
  end
end
