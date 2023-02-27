class CreateAwards < ActiveRecord::Migration[7.0]
  def change
    create_table :awards do |t|
      t.string :name
      t.integer :prize
      t.integer :ranking
      t.references :league, null: false, foreign_key: true
      t.boolean :status, default: true
      t.text :trophy_data

      t.timestamps
    end
  end
end
