class CreateDefTeams < ActiveRecord::Migration[7.0]
  def change
    create_table :def_teams do |t|
      t.string :name
      t.string :slug
      t.boolean :nation, default: false
      t.references :def_country, null: false, foreign_key: true
      t.boolean :active, default: true
      t.jsonb :details, default: {}, null: false
      t.text :platforms, default: [], array: true, null: false
      t.text :alias

      t.timestamps
    end
  end
end
