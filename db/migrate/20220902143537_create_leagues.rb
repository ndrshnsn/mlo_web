class CreateLeagues < ActiveRecord::Migration[7.0]
  def change
    create_table :leagues do |t|
      t.string :name
      t.references :user, null: false, foreign_key: true
      t.boolean :status
      t.string :slug
      t.string :platform
      t.text :badge_data

      t.timestamps
    end
  end
end
