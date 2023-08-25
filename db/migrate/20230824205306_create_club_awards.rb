class CreateClubAwards < ActiveRecord::Migration[7.0]
  def change
    create_table :club_awards do |t|
      t.references :club, null: false, foreign_key: true
      t.references :source, polymorphic: true, null: false

      t.timestamps
    end
  end
end