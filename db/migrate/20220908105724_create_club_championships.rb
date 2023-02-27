class CreateClubChampionships < ActiveRecord::Migration[7.0]
  def change
    create_table :club_championships do |t|
      t.references :club, null: false, foreign_key: true
      t.references :championship, null: false, foreign_key: true

      t.timestamps
    end
  end
end
