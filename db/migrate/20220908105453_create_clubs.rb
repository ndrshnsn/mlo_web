class CreateClubs < ActiveRecord::Migration[7.0]
  def change
    create_table :clubs do |t|
      t.references :def_team, null: false, foreign_key: true
      t.references :user_season, null: false, foreign_key: true
      t.jsonb :details, default: {}

      t.timestamps
    end
    add_index :clubs, :details, using: :gin
  end
end
