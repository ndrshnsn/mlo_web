class CreateUserSeasons < ActiveRecord::Migration[7.0]
  def change
    create_table :user_seasons do |t|
      t.references :user, null: false, foreign_key: true
      t.references :season, null: false, foreign_key: true
      t.jsonb :preferences, default: {}

      t.timestamps
    end
    add_index :user_seasons, :preferences, using: :gin
  end
end
