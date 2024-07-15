class CreateRankings < ActiveRecord::Migration[7.0]
  def change
    create_table :rankings do |t|
      t.references :season, null: false, foreign_key: true
      t.references :club, null: false, foreign_key: true
      t.integer :points
      t.string :operation
      t.integer :source_id
      t.string :source_type
      t.text :description
      t.integer :balance

      t.timestamps
    end
  end
end
