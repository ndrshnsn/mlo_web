class CreateUserLeagues < ActiveRecord::Migration[7.0]
  def change
    create_table :user_leagues do |t|
      t.references :user, null: false, foreign_key: true
      t.references :league, null: false, foreign_key: true
      t.boolean :status, default: false

      t.timestamps
    end
  end
end
