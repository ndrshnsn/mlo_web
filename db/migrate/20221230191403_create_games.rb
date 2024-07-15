class CreateGames < ActiveRecord::Migration[7.0]
  def change
    create_table :games do |t|
      t.references :championship, null: false, foreign_key: true
      t.references :home, null: false, foreign_key: {to_table: :clubs}
      t.references :visitor, null: false, foreign_key: {to_table: :clubs}
      t.integer :phase
      t.integer :hscore
      t.integer :vscore
      t.integer :phscore
      t.integer :pvscore
      t.integer :status
      t.boolean :hsaccepted, default: false
      t.boolean :vsaccepted, default: false
      t.boolean :hfaccepted, default: false
      t.boolean :vfaccepted, default: false
      t.references :eresults, null: false, foreign_key: {to_table: :clubs}
      t.boolean :wo, default: false
      t.boolean :mresult, default: false
      t.text :mdescription

      t.timestamps
    end
  end
end
