class CreateClubFinances < ActiveRecord::Migration[7.0]
  def change
    create_table :club_finances do |t|
      t.references :club, null: false, foreign_key: true
      t.string :operation
      t.integer :value
      t.integer :balance
      t.integer :source_id
      t.string :source_type
      t.text :description

      t.timestamps
    end
  end
end
