class CreateChampionships < ActiveRecord::Migration[7.0]
  def change
    create_table :championships do |t|
      t.string :name
      t.references :season, null: false, foreign_key: true
      t.text :badge_data
      t.integer :status
      t.text :advertisement
      t.jsonb :preferences, default: {}

      t.timestamps
    end
    add_index :championships, :preferences, using: :gin
  end
end
