class CreateChampionshipAwards < ActiveRecord::Migration[7.0]
  def change
    create_table :championship_awards do |t|
      t.references :championship, null: false, foreign_key: true
      t.references :award, null: false, foreign_key: true
      t.string :award_type, null: false

      t.timestamps
    end
  end
end
