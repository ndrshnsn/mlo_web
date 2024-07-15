class CreateSeasons < ActiveRecord::Migration[7.0]
  def change
    create_table :seasons do |t|
      t.string :name
      t.references :league, null: false, foreign_key: true
      t.jsonb :preferences, default: {}
      t.integer :status, default: 0
      t.text :advertisement
      t.date :start
      t.integer :duration

      t.timestamps
    end

    add_index :seasons, :preferences, using: :gin
  end
end
