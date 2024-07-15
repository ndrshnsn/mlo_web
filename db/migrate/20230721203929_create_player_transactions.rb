class CreatePlayerTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :player_transactions do |t|
      t.references :player_season, null: false, foreign_key: true
      t.references :from_club, null: true, foreign_key: { to_table: :clubs }
      t.references :to_club, null: true, foreign_key: { to_table: :clubs }
      t.string :transfer_mode
      t.integer :transfer_rate

      t.timestamps
    end
  end
end
