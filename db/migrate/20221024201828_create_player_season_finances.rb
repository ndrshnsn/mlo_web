class CreatePlayerSeasonFinances < ActiveRecord::Migration[7.0]
  def change
    create_table :player_season_finances do |t|
      t.references :player_season, null: false, foreign_key: true
      t.string :operation
      t.integer :value
      t.integer :source_id
      t.string :source_type

      t.timestamps
    end
  end
end
